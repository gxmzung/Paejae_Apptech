// lib/features/timetable/data/timetable_repo.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lecture_xlsx_loader.dart';
import '../domain/lecture_row.dart';
import '../domain/lecture_meeting.dart';
import 'package:apptech_flutter/features/timetable/timetable_keys.dart';

class TimeTableRepo extends ChangeNotifier {
  static const _assetPath = 'assets/data/lectures.xlsx';

  SharedPreferences? _sp;

  // ✅ 엑셀 로드는 앱 전체에서 1번만 (캐시)
  static List<LectureRow>? _allCache;

  List<LectureRow> _all = const [];

  // ✅ cart는 Set
  Set<String> _cartSet = <String>{};
  List<LectureRow> _cartRows = const [];

  // UI states
  String _query = '';
  String _divisionFilter = '전체';
  bool _editMode = false;

  // computed
  List<LectureRow> _filtered = const [];
  String _lastWarn = '';

  // ✅ 검색 인덱스
  final Map<String, String> _searchIndex = {};

  // ✅ query 디바운스
  Timer? _debounce;

  bool _inited = false;

  // getters
  bool get loading => !_inited;
  String get error => '';
  List<LectureRow> get selectedRows => cartRows;

  List<LectureRow> get all => _filtered;
  List<LectureRow> get cartRows => _cartRows;

  String get query => _query;
  String get divisionFilter => _divisionFilter;
  bool get editMode => _editMode;
  String get lastWarn => _lastWarn;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    if (_inited) return;
    _sp ??= await SharedPreferences.getInstance();
    await _loadAllLecturesCached();
    await _loadCart();
    _recompute(notify: true);
    _inited = true;
    notifyListeners();
  }

  Future<void> _loadAllLecturesCached() async {
    if (_allCache != null && _allCache!.isNotEmpty) {
      _all = _allCache!;
      _buildSearchIndexIfNeeded();
      return;
    }

    final loaded = await LectureXlsxLoader.loadFromAsset(_assetPath);
    _allCache = loaded;
    _all = loaded;
    _buildSearchIndexIfNeeded();
  }

  void _buildSearchIndexIfNeeded() {
    if (_searchIndex.isNotEmpty) return;
    for (final r in _all) {
      final k = lectureKeyOf(r);
      final s = ('${r.name} ${r.code} ${r.professor} ${r.room} ${r.division}')
          .toLowerCase();
      _searchIndex[k] = s;
    }
  }

  Future<void> _loadCart() async {
    final sp = _sp!;
    final raw = sp.getString(kTimetableCartKey);
    if (raw == null || raw.isEmpty) {
      _cartSet = <String>{};
      _cartRows = const [];
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).map((e) => e.toString());
      _cartSet = list.toSet();
    } catch (_) {
      _cartSet = <String>{};
    }
  }

  Future<void> _saveCart() async {
    final sp = _sp!;
    await sp.setString(kTimetableCartKey, jsonEncode(_cartSet.toList()));
  }

  void setQuery(String q) {
    _query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _recompute(notify: true);
    });
  }

  void setDivisionFilter(String f) {
    _divisionFilter = f;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      _recompute(notify: true);
    });
  }

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  bool isInCart(LectureRow r) => _cartSet.contains(lectureKeyOf(r));

  Future<void> add(LectureRow r) async {
    _lastWarn = '';

    // ✅ meetings가 비면 "엑셀 파싱 실패"로 보고 담기 막음
    if (r.meetings.isEmpty) {
      _lastWarn =
      '시간/요일 파싱이 실패했어.\n'
          '엑셀의 “강의실/강의시간” 형식이 예상과 달라서 그래.\n'
          '예: W306(수,A), W309(월D), P307(수10) 형태는 지원해.\n'
          '원본값: ${r.roomTimeRaw}';
      notifyListeners();
      return;
    }

    // 충돌 경고(추가는 진행)
    final clash = _findClash(r);
    if (clash != null) _lastWarn = '⚠️ 겹치는 강의가 있어: ${clash.name}';

    final key = lectureKeyOf(r);
    if (_cartSet.contains(key)) return;

    _cartSet.add(key);
    await _saveCart();
    _recompute(notify: true);
  }

  Future<void> remove(LectureRow r) async {
    final key = lectureKeyOf(r);
    if (!_cartSet.remove(key)) return;
    await _saveCart();
    _recompute(notify: true);
  }

  Future<void> clearCart() async {
    _cartSet = <String>{};
    await _saveCart();
    _recompute(notify: true);
  }

  // 필요하면 다시 살릴 수 있게 남겨둠
  Future<void> addAllVisible() async {
    _lastWarn = '전체 담기는 비활성화 상태야.';
    notifyListeners();
  }

  LectureRow? _findClash(LectureRow newRow) {
    for (final existing in _cartRows) {
      if (_meetingsOverlap(newRow.meetings, existing.meetings)) return existing;
    }
    return null;
  }

  bool _meetingsOverlap(List<LectureMeeting> a, List<LectureMeeting> b) {
    for (final x in a) {
      for (final y in b) {
        if (x.dayIndex != y.dayIndex) continue;
        final overlap = x.startMin < y.endMin && y.startMin < x.endMin;
        if (overlap) return true;
      }
    }
    return false;
  }

  void _recompute({required bool notify}) {
    // key -> row map
    final map = <String, LectureRow>{};
    for (final r in _all) {
      map[lectureKeyOf(r)] = r;
    }

    // cartRows
    final cart = <LectureRow>[];
    for (final k in _cartSet) {
      final v = map[k];
      if (v != null) cart.add(v);
    }
    _cartRows = cart;

    // filter/search
    final q = _query.trim().toLowerCase();
    final div = _divisionFilter;

    if (q.isEmpty && div == '전체') {
      _filtered = _all;
    } else {
      _filtered = _all.where((r) {
        if (div != '전체') {
          final d = r.division.trim();
          if (!d.contains(div)) return false;
        }
        if (q.isEmpty) return true;

        final k = lectureKeyOf(r);
        final s = _searchIndex[k] ?? '';
        return s.contains(q);
      }).toList(growable: false);
    }

    if (notify) notifyListeners();
  }

  List<String> getDivisionOptions() {
    final set = <String>{};
    for (final r in _all) {
      final d = r.division.trim();
      if (d.isNotEmpty) set.add(d);
    }
    final list = set.toList()..sort();
    return ['전체', ...list.take(12)];
  }
}