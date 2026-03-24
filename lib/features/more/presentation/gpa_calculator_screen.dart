// lib/features/more/presentation/gpa_calculator_screen.dart
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/more/data/lectures_xlsx_repo.dart';
import 'package:apptech_flutter/features/more/model/lecture.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  static const _kCourses = 'gpa_courses_v2';

  SharedPreferences? _sp;
  List<_Course> _courses = [];

  final TextEditingController _name = TextEditingController();
  int _credit = 3;
  String _grade = 'A0';

  final List<int> _creditOptions = const [1, 2, 3, 4, 5, 6];
  final List<String> _gradeOptions = const [
    'A+',
    'A0',
    'B+',
    'B0',
    'C+',
    'C0',
    'D+',
    'D0',
    'F',
    'P',
  ];

  // ===== XLSX(강의목록) =====
  List<Lecture> _lectures = [];
  bool _lecturesLoading = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    _sp = await SharedPreferences.getInstance();
    await _load();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadLecturesOnce() async {
    if (_lectures.isNotEmpty || _lecturesLoading) return;

    if (mounted) setState(() => _lecturesLoading = true);

    try {
      _lectures = await LecturesXlsxRepo.loadFromAssets(
        assetPath: 'assets/data/lectures.xlsx',
      );
    } catch (e) {
      _lectures = [];
      _toast('엑셀 과목 목록 로드 실패: $e');
    }

    if (!mounted) return;
    setState(() => _lecturesLoading = false);
  }

  Future<void> _load() async {
    final sp = _sp!;
    final raw = sp.getString(_kCourses);

    if (raw == null || raw.isEmpty) {
      _courses = [
        _Course(id: '1', name: '이산수학', credit: 3, grade: 'A0'),
        _Course(id: '2', name: '프로그래밍', credit: 3, grade: 'A+'),
      ];
      await _save();
      return;
    }

    try {
      final list = (jsonDecode(raw) as List).cast<Map>();
      _courses =
          list.map((m) => _Course.fromMap(m.cast<String, dynamic>())).toList();
    } catch (_) {
      _courses = [];
    }
  }

  Future<void> _save() async {
    final sp = _sp!;
    await sp.setString(
      _kCourses,
      jsonEncode(_courses.map((e) => e.toMap()).toList()),
    );
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  double _gradePoint(String g) {
    switch (g) {
      case 'A+':
        return 4.5;
      case 'A0':
        return 4.0;
      case 'B+':
        return 3.5;
      case 'B0':
        return 3.0;
      case 'C+':
        return 2.5;
      case 'C0':
        return 2.0;
      case 'D+':
        return 1.5;
      case 'D0':
        return 1.0;
      case 'F':
        return 0.0;
      case 'P':
        return -1; // Pass: GPA 제외
      default:
        return 0.0;
    }
  }

  ({double gpa, int creditsCounted, int creditsTotal}) _calc() {
    double sum = 0;
    int creditsCounted = 0;
    int creditsTotal = 0;

    for (final c in _courses) {
      creditsTotal += c.credit;
      final gp = _gradePoint(c.grade);
      if (gp < 0) continue; // P 제외
      creditsCounted += c.credit;
      sum += gp * c.credit;
    }

    final gpa = creditsCounted == 0 ? 0.0 : (sum / creditsCounted);
    return (
    gpa: gpa,
    creditsCounted: creditsCounted,
    creditsTotal: creditsTotal,
    );
  }

  Map<String, int> _gradeDist() {
    // P는 별도 카운트(학점 기준)
    final m = <String, int>{
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'F': 0,
      'P': 0,
    };
    for (final c in _courses) {
      if (c.grade == 'P') {
        m['P'] = (m['P'] ?? 0) + c.credit;
        continue;
      }
      final head = c.grade.isEmpty ? 'F' : c.grade[0]; // A/B/C/D/F
      if (!m.containsKey(head)) continue;
      m[head] = (m[head] ?? 0) + c.credit;
    }
    return m;
  }

  Future<void> _add() async {
    final n = _name.text.trim();
    if (n.isEmpty) {
      _toast('과목명을 써줘!');
      return;
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _courses.insert(0, _Course(id: id, name: n, credit: _credit, grade: _grade));
    _name.clear();
    await _save();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _remove(_Course c) async {
    _courses.removeWhere((e) => e.id == c.id);
    await _save();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _edit(_Course c) async {
    final name = TextEditingController(text: c.name);
    int credit = c.credit;
    String grade = c.grade;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: StatefulBuilder(
              builder: (context, setM) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '과목 수정',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.paejaeNavy,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      hintText: '과목명',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                        BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.paejaeBlue.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Dropdown<int>(
                          label: '학점',
                          value: credit,
                          items: _creditOptions,
                          toText: (v) => '$v',
                          onChanged: (v) => setM(() => credit = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Dropdown<String>(
                          label: '등급',
                          value: grade,
                          items: _gradeOptions,
                          toText: (v) => v,
                          onChanged: (v) => setM(() => grade = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: Colors.black.withValues(alpha: 0.10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            '취소',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.paejaeBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            '저장',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    final nn = name.text.trim();
    if (nn.isEmpty) {
      _toast('과목명은 비울 수 없어!');
      return;
    }

    final idx = _courses.indexWhere((e) => e.id == c.id);
    if (idx < 0) return;

    _courses[idx] = _Course(id: c.id, name: nn, credit: credit, grade: grade);
    await _save();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('초기화할까?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          '등록한 과목 목록을 모두 지워요.',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _courses.clear();
    await _save();
    if (!mounted) return;
    setState(() {});
  }

  // ✅ 핵심: 바텀시트에서 Lecture를 반환받아 여기서 바로 추가/저장
  Future<void> _openLecturePicker() async {
    await _loadLecturesOnce();
    if (!mounted) return;

    if (_lectures.isEmpty) {
      _toast('엑셀에 과목이 없거나 파싱 실패했어.');
      return;
    }

    final picked = await showModalBottomSheet<Lecture>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LecturePickerSheet(lectures: _lectures),
    );

    if (picked == null) return;

    // 중복 방지(이름 기준). 원하면 code 기준으로 바꿔도 됨.
    final exists = _courses.any((c) => c.name.trim() == picked.name.trim());
    if (exists) {
      _toast('이미 추가된 과목이야!');
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _courses.insert(
      0,
      _Course(
        id: id,
        name: picked.name,
        credit: picked.credit,
        grade: _grade, // 현재 선택된 등급을 기본값으로
      ),
    );

    try {
      await _save();
    } catch (e) {
      _toast('저장 실패: $e');
      return;
    }

    if (!mounted) return;
    setState(() {});
    _toast('추가됨: ${picked.name}');
  }

  @override
  Widget build(BuildContext context) {
    final res = _calc();
    final dist = _gradeDist();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('학점 계산기', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        actions: [
          IconButton(
            tooltip: '초기화',
            onPressed: _courses.isEmpty ? null : _reset,
            icon: const Icon(Icons.delete_forever_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          // ===== Hero (Gradient) =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.paejaeBlue,
                  AppColors.paejaeBlue.withValues(alpha: 0.82),
                  const Color(0xFF0B2B5A).withValues(alpha: 0.92),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Pill(
                      icon: Icons.school_rounded,
                      text: '학점/GPA',
                      fg: Colors.white,
                      bg: Colors.white.withValues(alpha: 0.14),
                      border: Colors.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      icon: Icons.calculate_rounded,
                      text: '자동계산',
                      fg: Colors.white,
                      bg: Colors.white.withValues(alpha: 0.14),
                      border: Colors.white.withValues(alpha: 0.18),
                    ),
                    const Spacer(),
                    _Pill(
                      icon: Icons.check_circle_rounded,
                      text: 'P 제외',
                      fg: Colors.white,
                      bg: Colors.white.withValues(alpha: 0.14),
                      border: Colors.white.withValues(alpha: 0.18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '현재 GPA',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      res.gpa.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 44,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        ' / 4.5',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CustomPaint(
                        painter: _RingPainter(
                          progress: (res.gpa / 4.5).clamp(0.0, 1.0),
                          color: Colors.white,
                          bgColor: Colors.white.withValues(alpha: 0.22),
                        ),
                        child: Center(
                          child: Text(
                            '${((res.gpa / 4.5) * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '반영 학점 ${res.creditsCounted} / 전체 학점 ${res.creditsTotal} (P는 GPA에서 제외)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== Grade distribution graph =====
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '학점 분포(학점 기준)',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.paejaeNavy,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _GradeBarPainter(
                      dist: dist,
                      blue: AppColors.paejaeBlue,
                      navy: AppColors.paejaeNavy,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipStat(label: 'A', value: '${dist['A'] ?? 0}학점'),
                    _ChipStat(label: 'B', value: '${dist['B'] ?? 0}학점'),
                    _ChipStat(label: 'C', value: '${dist['C'] ?? 0}학점'),
                    _ChipStat(label: 'D', value: '${dist['D'] ?? 0}학점'),
                    _ChipStat(label: 'F', value: '${dist['F'] ?? 0}학점'),
                    _ChipStat(label: 'P', value: '${dist['P'] ?? 0}학점'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===== Add course =====
          const Text('과목 추가',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          _Card(
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    hintText: '과목명 (예: 자료구조)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.paejaeBlue.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Dropdown<int>(
                        label: '학점',
                        value: _credit,
                        items: _creditOptions,
                        toText: (v) => '$v',
                        onChanged: (v) => setState(() => _credit = v),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Dropdown<String>(
                        label: '등급',
                        value: _grade,
                        items: _gradeOptions,
                        toText: (v) => v,
                        onChanged: (v) => setState(() => _grade = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paejaeBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('추가', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ XLSX에서 과목 찾아서 "바로 추가"
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _lecturesLoading ? null : _openLecturePicker,
                    icon: Icon(_lecturesLoading
                        ? Icons.hourglass_top_rounded
                        : Icons.file_open_rounded),
                    label: Text(
                      _lecturesLoading ? '불러오는 중...' : '엑셀에서 과목 찾아서 추가',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== Course list =====
          Row(
            children: [
              const Text('과목 목록',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              Text(
                '${_courses.length}개',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_courses.isEmpty)
            _Card(
              child: Text(
                '과목이 없어요. 위에서 추가해줘!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.70),
                ),
              ),
            )
          else
            ..._courses.map(
                  (c) => _CourseTile(
                course: c,
                onEdit: () => _edit(c),
                onDelete: () => _remove(c),
              ),
            ),
        ],
      ),
    );
  }
}

// ====== Models ======

class _Course {
  final String id;
  final String name;
  final int credit;
  final String grade;

  const _Course({
    required this.id,
    required this.name,
    required this.credit,
    required this.grade,
  });

  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'credit': credit, 'grade': grade};

  static _Course fromMap(Map<String, dynamic> m) => _Course(
    id: (m['id'] ?? '').toString(),
    name: (m['name'] ?? '').toString(),
    credit: (m['credit'] ?? 3) as int,
    grade: (m['grade'] ?? 'A0').toString(),
  );
}

// ====== Widgets ======

class _CourseTile extends StatelessWidget {
  final _Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseTile({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  Color _gradeColor(String g) {
    if (g == 'P') return const Color(0xFF6C7A89);
    switch (g[0]) {
      case 'A':
        return const Color(0xFF2E7D32);
      case 'B':
        return const Color(0xFF1565C0);
      case 'C':
        return const Color(0xFFEAA200);
      case 'D':
        return const Color(0xFFE07A2E);
      default:
        return const Color(0xFFE04F5F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _gradeColor(course.grade);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.withValues(alpha: 0.18)),
                ),
                child: Center(
                  child: Text(
                    course.grade,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: c,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.credit}학점',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '삭제',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.redAccent,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) toText;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.toText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
              value: e,
              child: Text(toText(e),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  const _ChipStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              )),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy.withValues(alpha: 0.70),
              )),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color fg;
  final Color bg;
  final Color border;

  const _Pill({
    required this.icon,
    required this.text,
    required this.fg,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontWeight: FontWeight.w900, color: fg)),
        ],
      ),
    );
  }
}

// ======= XLSX Lecture Picker (Navigator.pop으로 Lecture 반환) =======

class _LecturePickerSheet extends StatefulWidget {
  final List<Lecture> lectures;

  const _LecturePickerSheet({
    required this.lectures,
  });

  @override
  State<_LecturePickerSheet> createState() => _LecturePickerSheetState();
}

class _LecturePickerSheetState extends State<_LecturePickerSheet> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final qq = q.trim().toLowerCase();
    final list = widget.lectures.where((e) {
      if (qq.isEmpty) return true;
      final s = ('${e.name} ${e.code} ${e.type}').toLowerCase();
      return s.contains(qq);
    }).take(250).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('과목 검색(엑셀)', style: TextStyle(fontWeight: FontWeight.w900)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: InputDecoration(
                hintText: '과목명/과목코드/이수구분 검색',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.paejaeBlue.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.black.withValues(alpha: 0.06)),
                itemBuilder: (_, i) {
                  final lec = list[i];
                  return ListTile(
                    title: Text(lec.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text(
                      '${lec.type} · ${lec.code} · ${lec.credit}학점',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    onTap: () => Navigator.pop(context, lec),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= Painters =======

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color bgColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final r = (math.min(size.width, size.height) / 2) - stroke / 2;
    final c = Offset(size.width / 2, size.height / 2);

    final bg = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, bg);

    final start = -math.pi / 2;
    final sweep = (2 * math.pi) * progress.clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.bgColor != bgColor;
  }
}

class _GradeBarPainter extends CustomPainter {
  final Map<String, int> dist;
  final Color blue;
  final Color navy;

  _GradeBarPainter({
    required this.dist,
    required this.blue,
    required this.navy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 10.0;
    final rect = Rect.fromLTWH(
      pad,
      pad,
      size.width - pad * 2,
      size.height - pad * 2,
    );

    // background
    final bg = Paint()..color = Colors.black.withValues(alpha: 0.04);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      bg,
    );

    const keys = ['A', 'B', 'C', 'D', 'F', 'P'];
    final values = keys.map((k) => (dist[k] ?? 0)).toList();
    final maxV = math.max(1, values.fold<int>(0, (a, b) => math.max(a, b)));

    final barW = rect.width / keys.length;
    for (int i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = dist[k] ?? 0;
      final h = rect.height * (v / maxV);

      final x = rect.left + i * barW + 6;
      final y = rect.bottom - h;
      final w = barW - 12;

      Color c;
      switch (k) {
        case 'A':
          c = const Color(0xFF2E7D32);
          break;
        case 'B':
          c = const Color(0xFF1565C0);
          break;
        case 'C':
          c = const Color(0xFFEAA200);
          break;
        case 'D':
          c = const Color(0xFFE07A2E);
          break;
        case 'F':
          c = const Color(0xFFE04F5F);
          break;
        default:
          c = const Color(0xFF6C7A89);
      }

      final p = Paint()..color = c.withValues(alpha: 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), const Radius.circular(12)),
        p,
      );

      // label
      final tp = TextPainter(
        text: TextSpan(
          text: k,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: navy.withValues(alpha: 0.65),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 40);

      tp.paint(canvas, Offset(x + (w - tp.width) / 2, rect.bottom + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GradeBarPainter oldDelegate) {
    return oldDelegate.dist != dist;
  }
}