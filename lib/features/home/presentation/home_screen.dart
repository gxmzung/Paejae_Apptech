import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/academic/academic_calendar_screen.dart';
import 'package:apptech_flutter/features/timetable/data/timetable_repo.dart';
import 'package:apptech_flutter/features/timetable/domain/lecture_row.dart';
import 'package:apptech_flutter/features/timetable/presentation/timetable_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MealItem {
  final String title;
  final String place;
  final List<String> menus;
  final DateTime updatedAt;

  const MealItem({
    required this.title,
    required this.place,
    required this.menus,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'place': place,
    'menus': menus,
    'updatedAtMs': updatedAt.millisecondsSinceEpoch,
  };

  factory MealItem.fromJson(Map<String, dynamic> j) {
    return MealItem(
      title: (j['title'] ?? '').toString(),
      place: (j['place'] ?? '').toString(),
      menus: ((j['menus'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (j['updatedAtMs'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const String _kStepDayKey = 'steps_day_yyyymmdd_v2';
  static const String _kStepBaselineTotalKey = 'steps_baseline_total_v2';
  static const String _kStepLastTotalKey = 'steps_last_total_v2';

  static const String _kMealCacheKey = 'meal_cache_today_v3';
  static const String _kMealCacheDayKey = 'meal_cache_day_v3';

  static const int _dailyGoalSteps = 3000;
  static const double _strideMeters = 0.70;
  static const double _kcalPerStep = 0.04;
  static const String _dietUrl = 'https://www.pcu.ac.kr/kor/29/diet';

  SharedPreferences? _sp;

  int _steps = 0;
  double _km = 0.0;
  int _kcal = 0;

  StreamSubscription<StepCount>? _stepSub;
  int? _baselineStepsTotal;
  int? _lastStepsTotal;

  bool _stepStreamAlive = false;
  String _stepErrorMsg = '';
  DateTime? _lastStepEventAt;

  bool _mealLoading = true;
  String _mealErr = '';
  MealItem? _meal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _boot();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMeal();
    }
  }

  Future<void> _boot() async {
    _sp = await SharedPreferences.getInstance();
    await _initPedometer();
    await _loadMeal();
  }

  String _yyyymmdd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  String get _todayKey => _yyyymmdd(DateTime.now());

  String _weekdayKo(DateTime d) {
    const map = ['월', '화', '수', '목', '금', '토', '일'];
    return map[d.weekday - 1];
  }

  String get _todayPretty {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} (${_weekdayKo(now)})';
  }

  String _oneLineInfo(List<LectureRow> rows) {
    if (rows.isEmpty) {
      return '오늘도 배재Pick으로 학교생활 정리해보자!';
    }
    return '오늘 담긴 수업 ${rows.length}개 · 자주 쓰는 기능을 바로 열어보자';
  }

  String _timeSnapAsset() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 8) {
      return 'assets/timesnap/dawn.png';
    }
    if (hour >= 8 && hour < 12) {
      return 'assets/timesnap/morning.png';
    }
    if (hour >= 12 && hour < 17) {
      return 'assets/timesnap/noon.png';
    }
    if (hour >= 17 && hour < 20) {
      return 'assets/timesnap/sunset.png';
    }
    return 'assets/timesnap/night.png';
  }

  Future<bool> _requestStepPermission() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    }
    if (Platform.isIOS) return true;
    return false;
  }

  Future<void> _initPedometer() async {
    final ok = await _requestStepPermission();
    if (!ok) return;

    final sp = _sp!;
    final savedDay = sp.getString(_kStepDayKey) ?? '';
    if (savedDay != _todayKey) {
      await sp.setString(_kStepDayKey, _todayKey);
      await sp.remove(_kStepBaselineTotalKey);
      await sp.remove(_kStepLastTotalKey);
      _baselineStepsTotal = null;
      _lastStepsTotal = null;
      if (mounted) {
        setState(() {
          _steps = 0;
          _km = 0.0;
          _kcal = 0;
        });
      }
    } else {
      _baselineStepsTotal = sp.getInt(_kStepBaselineTotalKey);
      _lastStepsTotal = sp.getInt(_kStepLastTotalKey);
    }

    _stepSub?.cancel();

    _stepSub = Pedometer.stepCountStream.listen(
          (event) async {
        final sp2 = _sp!;
        final total = event.steps;

        _lastStepEventAt = DateTime.now();
        if (!_stepStreamAlive && mounted) {
          setState(() => _stepStreamAlive = true);
        }

        final day = sp2.getString(_kStepDayKey) ?? '';
        if (day != _todayKey) {
          await sp2.setString(_kStepDayKey, _todayKey);
          await sp2.remove(_kStepBaselineTotalKey);
          await sp2.remove(_kStepLastTotalKey);
          _baselineStepsTotal = null;
          _lastStepsTotal = null;
        }

        if (_baselineStepsTotal == null) {
          _baselineStepsTotal = total;
          await sp2.setInt(_kStepBaselineTotalKey, total);
        }

        if (_lastStepsTotal != null && total < (_lastStepsTotal ?? total)) {
          _baselineStepsTotal = total;
          await sp2.setInt(_kStepBaselineTotalKey, total);
        }

        _lastStepsTotal = total;
        await sp2.setInt(_kStepLastTotalKey, total);

        final baseline = _baselineStepsTotal ?? total;
        int todaySteps = total - baseline;
        if (todaySteps < 0) todaySteps = 0;
        if (todaySteps > 200000) todaySteps = 200000;

        final km = (todaySteps * _strideMeters) / 1000.0;
        final kcal = (todaySteps * _kcalPerStep).round();

        if (!mounted) return;
        setState(() {
          _steps = todaySteps;
          _km = km;
          _kcal = kcal;
          _stepErrorMsg = '';
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _stepStreamAlive = false;
          _stepErrorMsg = e.toString();
        });
      },
      cancelOnError: false,
    );
  }

  int _weekdayIndexMon0(DateTime d) {
    final w = d.weekday;
    if (w < DateTime.monday || w > DateTime.friday) return -1;
    return w - 1;
  }

  String _cleanCell(String s) {
    var x = s.replaceAll('\u00A0', ' ');
    x = x.replaceAll(RegExp(r'[ \t]+'), ' ');
    x = x.replaceAll(RegExp(r'\n\s*\n+'), '\n');
    return x.trim();
  }

  bool _looksLikeWeekdayHeader(List<String> headers) {
    const targets = ['월', '화', '수', '목', '금'];
    int hit = 0;
    for (final t in targets) {
      if (headers.any((h) => h.contains(t))) hit++;
    }
    return hit >= 3;
  }

  String _nearestSectionTitle(dom.Element table) {
    dom.Node? n = table;
    int guard = 0;
    while (n != null && guard++ < 60) {
      final parent = n.parent;
      if (parent is dom.Element) {
        final siblings = parent.nodes;
        final idx = siblings.indexOf(n);
        for (int i = idx - 1; i >= 0; i--) {
          final s = siblings[i];
          if (s is dom.Element) {
            final tag = s.localName ?? '';
            final tx = _cleanCell(s.text);
            if (tx.isEmpty) continue;
            if (tag == 'h1' ||
                tag == 'h2' ||
                tag == 'h3' ||
                tag == 'h4' ||
                tag == 'h5') {
              return tx;
            }
            if (tx.contains('중식') ||
                tx.contains('조식') ||
                tx.contains('석식') ||
                tx.contains('학생식당') ||
                tx.contains('교직원식당')) {
              return tx;
            }
          }
        }
      }
      n = parent;
    }
    return '오늘의 학식';
  }

  Future<MealItem?> _fetchMealFromPcuDiet() async {
    final idx = _weekdayIndexMon0(DateTime.now());
    if (idx < 0) {
      return MealItem(
        title: '오늘의 학식',
        place: '배재대학교',
        menus: const ['주말/공휴일은 식단 정보가 없을 수 있어요.'],
        updatedAt: DateTime.now(),
      );
    }

    final res =
    await http.get(Uri.parse(_dietUrl)).timeout(const Duration(seconds: 10));

    String html;
    try {
      html = utf8.decode(res.bodyBytes);
    } catch (_) {
      html = latin1.decode(res.bodyBytes);
    }

    final doc = html_parser.parse(html);
    final tables = doc.querySelectorAll('table');
    final candidates = <MealItem>[];

    for (final tb in tables) {
      final rows = tb.querySelectorAll('tr');
      if (rows.isEmpty) continue;

      final headerCells = rows.first.querySelectorAll('th,td');
      final headers = headerCells.map((e) => _cleanCell(e.text)).toList();
      if (!_looksLikeWeekdayHeader(headers)) continue;

      dom.Element? dataRow;
      for (int r = 1; r < rows.length; r++) {
        final tds = rows[r].querySelectorAll('td');
        if (tds.length >= 5) {
          dataRow = rows[r];
          break;
        }
      }
      if (dataRow == null) continue;

      final tds = dataRow.querySelectorAll('td');
      if (tds.length < 5) continue;

      final cell = tds[idx];
      final rawText = _cleanCell(cell.text);
      if (rawText.isEmpty) continue;

      final lines =
      rawText.split('\n').map(_cleanCell).where((e) => e.isNotEmpty).toList();
      if (lines.isEmpty) continue;

      final titleGuess = _nearestSectionTitle(tb);
      String placeGuess = '배재대학교';
      if (titleGuess.contains('학생식당')) placeGuess = '학생식당';
      if (titleGuess.contains('교직원식당')) placeGuess = '교직원식당';

      String niceTitle = '오늘의 학식';
      if (titleGuess.contains('조식')) niceTitle = '조식';
      if (titleGuess.contains('중식')) niceTitle = '중식';
      if (titleGuess.contains('석식')) niceTitle = '석식';

      candidates.add(
        MealItem(
          title: niceTitle,
          place: placeGuess,
          menus: lines,
          updatedAt: DateTime.now(),
        ),
      );
    }

    if (candidates.isEmpty) return null;

    return candidates.firstWhere(
          (m) => m.place.contains('학생') && m.title.contains('중식'),
      orElse: () => candidates.first,
    );
  }

  Future<void> _loadMeal() async {
    try {
      if (mounted) {
        setState(() {
          _mealLoading = true;
          _mealErr = '';
        });
      }

      final sp = _sp!;
      final day = sp.getString(_kMealCacheDayKey) ?? '';
      final cached = sp.getString(_kMealCacheKey);

      if (day == _todayKey && cached != null && cached.isNotEmpty) {
        try {
          final m = MealItem.fromJson(jsonDecode(cached));
          if (mounted) {
            setState(() {
              _meal = m;
              _mealLoading = false;
            });
          }
        } catch (_) {}
      }

      final fetched = await _fetchMealFromPcuDiet();
      if (fetched == null) {
        if (!mounted) return;
        setState(() {
          _mealLoading = false;
          _mealErr = _meal == null ? '식단 정보를 불러오지 못했어요.' : '';
          _meal ??= MealItem(
            title: '오늘의 학식',
            place: '배재대학교',
            menus: const ['식단 정보를 불러오지 못했어요.'],
            updatedAt: DateTime.now(),
          );
        });
        return;
      }

      await sp.setString(_kMealCacheDayKey, _todayKey);
      await sp.setString(_kMealCacheKey, jsonEncode(fetched.toJson()));

      if (!mounted) return;
      setState(() {
        _meal = fetched;
        _mealLoading = false;
        _mealErr = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mealLoading = false;
        _mealErr = e.toString();
        _meal ??= MealItem(
          title: '오늘의 학식',
          place: '배재대학교',
          menus: const ['식단 정보를 불러오지 못했어요.'],
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  Future<void> _refreshAll() async {
    await _loadMeal();
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _openQrDialog({
    required String title,
    required String subtitle,
    required String assetPath,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 220,
                height: 220,
                color: Colors.white,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black.withOpacity(0.03),
                    alignment: Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'QR 이미지를 assets에 넣으면 바로 사용 가능해.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ttRepo = context.watch<TimeTableRepo>();
    final myRows = ttRepo.cartRows;
    final progress = (_steps / _dailyGoalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        centerTitle: true,
        title: const Text(
          '배재Pick',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _AdCardFixed(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          _HeroCampusCard(
            dateText: _todayPretty,
            infoText: _oneLineInfo(myRows),
            imageAsset: _timeSnapAsset(),
          ),
          const SizedBox(height: 16),
          const _SectionHeader(
            title: '빠른 실행',
            subtitle: '자주 쓰는 기능을 바로 열어보자',
          ),
          const SizedBox(height: 10),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              _QuickCard(
                icon: Icons.calendar_month_rounded,
                title: '시간표',
                subtitle: myRows.isEmpty ? '과목 담기 / 편집' : '내 시간표 바로 열기',
                onTap: () =>
                    Navigator.pushNamed(context, TimeTableScreen.routeName),
              ),
              _QuickCard(
                icon: Icons.restaurant_rounded,
                title: '학식',
                subtitle: _meal?.menus.isNotEmpty == true
                    ? _meal!.menus.first
                    : (_mealLoading ? '불러오는 중...' : '오늘 식단 보기'),
                onTap: () => _openPage(
                  context,
                  _SimpleListPage(
                    title: '오늘의 학식',
                    subtitle: _mealErr.isNotEmpty
                        ? _mealErr
                        : (_meal == null
                        ? '식단 정보가 없어요.'
                        : '${_meal!.place} · ${_meal!.title}'),
                    items: _meal?.menus ?? const ['식단 정보를 불러오지 못했어요.'],
                  ),
                ),
              ),
              _QuickCard(
                icon: Icons.qr_code_2_rounded,
                title: '도서관 QR',
                subtitle: '입장용 QR 바로 열기',
                onTap: () => _openQrDialog(
                  title: '도서관 QR',
                  subtitle: '실제 QR 이미지 또는 웹 링크로 교체하면 돼.',
                  assetPath: 'assets/qr/library_qr.png',
                ),
              ),
              _QuickCard(
                icon: Icons.meeting_room_rounded,
                title: 'P라운지 QR',
                subtitle: '출입용 QR 바로 열기',
                onTap: () => _openQrDialog(
                  title: 'P라운지 QR',
                  subtitle: '실제 QR 이미지 또는 웹 링크로 교체하면 돼.',
                  assetPath: 'assets/qr/p_lounge_qr.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: '학교 정보',
            subtitle: '학교생활 핵심 정보 모음',
          ),
          const SizedBox(height: 10),
          _InfoRowCard(
            icon: Icons.event_note_rounded,
            title: '학사일정',
            subtitle: '중간고사, 종강, 휴일 등 주요 일정 확인',
            onTap: () => _openPage(context, AcademicCalendarScreen()),
          ),
          const SizedBox(height: 10),
          _InfoRowCard(
            icon: Icons.notifications_active_rounded,
            title: '공지 / 장학금',
            subtitle: '중요 공지, 장학금, 학교 소식 모아보기',
            onTap: () => _openPage(
              context,
              const _SimplePlaceholderPage(
                title: '공지 / 장학금',
                message: '여기에 공지 / 장학금 화면을 연결하면 돼.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRowCard(
            icon: Icons.map_rounded,
            title: '캠퍼스 지도',
            subtitle: '건물, 편의시설, 주요 위치 찾기',
            onTap: () => _openPage(
              context,
              const _SimplePlaceholderPage(
                title: '캠퍼스 지도',
                message: '캠퍼스 지도 화면을 여기에 연결하면 돼.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          _InfoRowCard(
            icon: Icons.meeting_room_outlined,
            title: '강의실 빈 시간 찾기',
            subtitle: '현재 / 다음 시간대 사용 가능한 강의실 찾기',
            onTap: () => _openPage(
              context,
              const _SimplePlaceholderPage(
                title: '강의실 빈 시간 찾기',
                message: '시간표 데이터 기반 빈 강의실 기능을 여기에 붙이면 돼.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: '내 학교생활',
            subtitle: '개인 관리 도구',
          ),
          const SizedBox(height: 10),
          _WalkSummaryCard(
            steps: _steps,
            km: _km,
            kcal: _kcal,
            progress: progress,
            errorText: _stepErrorMsg,
            streamAlive: _stepStreamAlive,
            lastEventAt: _lastStepEventAt,
          ),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            children: [
              _ToolMiniCard(
                icon: Icons.how_to_reg_rounded,
                title: '개인 출석 기록',
                subtitle: '공식 출결 아님',
                onTap: () => _openPage(
                  context,
                  const _SimplePlaceholderPage(
                    title: '개인 출석 기록',
                    message: '개인용 출석 체크 도구를 여기에 붙이면 돼.',
                  ),
                ),
              ),
              _ToolMiniCard(
                icon: Icons.calculate_rounded,
                title: '학점 계산기',
                subtitle: '예상 학점 계산',
                onTap: () => _openPage(
                  context,
                  const _SimplePlaceholderPage(
                    title: '학점 계산기',
                    message: '학점 계산기 화면을 여기에 연결하면 돼.',
                  ),
                ),
              ),
              _ToolMiniCard(
                icon: Icons.rule_folder_rounded,
                title: '졸업 체크',
                subtitle: '이수 현황 점검',
                onTap: () => _openPage(
                  context,
                  const _SimplePlaceholderPage(
                    title: '졸업 체크',
                    message: '졸업 요건 체크 기능을 여기에 붙이면 돼.',
                  ),
                ),
              ),
              _ToolMiniCard(
                icon: Icons.note_alt_rounded,
                title: '학교생활 메모',
                subtitle: '오늘 기록 남기기',
                onTap: () => _openPage(
                  context,
                  const _SimplePlaceholderPage(
                    title: '학교생활 메모',
                    message: '간단한 개인 메모 기능을 여기에 붙이면 돼.',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _HeroCampusCard extends StatelessWidget {
  final String dateText;
  final String infoText;
  final String imageAsset;

  const _HeroCampusCard({
    required this.dateText,
    required this.infoText,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003A8C), Color(0xFF0052CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.50),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '배재Pick',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    infoText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.paejaeNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.paejaeBlue),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.58),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRowCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InfoRowCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.paejaeBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.paejaeNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkSummaryCard extends StatelessWidget {
  final int steps;
  final double km;
  final int kcal;
  final double progress;
  final String errorText;
  final bool streamAlive;
  final DateTime? lastEventAt;

  const _WalkSummaryCard({
    required this.steps,
    required this.km,
    required this.kcal,
    required this.progress,
    required this.errorText,
    required this.streamAlive,
    required this.lastEventAt,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    final debugLine = streamAlive
        ? '센서 정상${lastEventAt == null ? '' : ' · 마지막 이벤트 기록됨'}'
        : (errorText.isEmpty ? '센서 대기 중' : errorText);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF003A8C), Color(0xFF0052CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '걸음수',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              Text(
                '$steps steps',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: '거리',
                    value: km.toStringAsFixed(1),
                    unit: 'km',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricChip(
                    label: '칼로리',
                    value: '$kcal',
                    unit: 'kcal',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: safeProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              debugLine,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.paejaeBlue),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdCardFixed extends StatelessWidget {
  const _AdCardFixed();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: AppColors.paejaeBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '광고 영역',
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  '협업 카페 배너(1000명 다운로드 이후)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'BANNER',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplePlaceholderPage extends StatelessWidget {
  final String title;
  final String message;

  const _SimplePlaceholderPage({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleListPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> items;

  const _SimpleListPage({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
                (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Text(
                e,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}