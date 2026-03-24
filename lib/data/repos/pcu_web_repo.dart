import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PcuWebRepo {
  // ----- Links -----
  static const academyUrl = 'https://www.pcu.ac.kr/kor/contents/87'; // 배재학당
  static const eduIdeologyUrl = 'https://www.pcu.ac.kr/kor/contents/80'; // 교육이념
  static const historyUrl = 'https://www.pcu.ac.kr/kor/contents/81'; // 연혁
  static const prideUrl = 'https://www.pcu.ac.kr/kor/38/pcuPride'; // PRIDE
  static const academicCalendarUrl = 'https://www.pcu.ac.kr/kor/30/schedules/CAT072';

  static const Duration cacheTtl = Duration(hours: 24);

  // ----- Cache keys (4 Tabs) -----
  static const _kCacheAcademy = 'pcu_cache_tab_academy_v2';
  static const _kCacheEdu = 'pcu_cache_tab_edu_ideology_v2';
  static const _kCacheHistory = 'pcu_cache_tab_history_v2';
  static const _kCachePride = 'pcu_cache_tab_pride_v2';

  static const _kFetchedAcademy = 'pcu_cache_tab_academy_fetchedAt_v2';
  static const _kFetchedEdu = 'pcu_cache_tab_edu_ideology_fetchedAt_v2';
  static const _kFetchedHistory = 'pcu_cache_tab_history_fetchedAt_v2';
  static const _kFetchedPride = 'pcu_cache_tab_pride_fetchedAt_v2';

  // ----- Cache keys (Academic Calendar) -----
  static const _kCacheAcademicCalendar = 'pcu_cache_academic_calendar_v1';
  static const _kFetchedAcademicCalendar = 'pcu_cache_academic_calendar_fetchedAt_v1';

  // =============================
  // Public APIs (4 Tabs)
  // =============================

  Future<PcuPageDoc> loadTabAcademy({bool forceRefresh = false}) async {
    return _loadDoc(
      url: academyUrl,
      cacheKey: _kCacheAcademy,
      fetchedAtKey: _kFetchedAcademy,
      parser: _parseGenericDocWithHeadings,
      forceRefresh: forceRefresh,
    );
  }

  Future<PcuPageDoc> loadTabEduIdeology({bool forceRefresh = false}) async {
    return _loadDoc(
      url: eduIdeologyUrl,
      cacheKey: _kCacheEdu,
      fetchedAtKey: _kFetchedEdu,
      parser: _parseGenericDocWithHeadings,
      forceRefresh: forceRefresh,
    );
  }

  Future<PcuTimelineDoc> loadTabHistory({bool forceRefresh = false}) async {
    return _loadTimeline(
      url: historyUrl,
      cacheKey: _kCacheHistory,
      fetchedAtKey: _kFetchedHistory,
      forceRefresh: forceRefresh,
    );
  }

  Future<PcuPrideDoc> loadTabPride({bool forceRefresh = false}) async {
    return _loadPride(
      url: prideUrl,
      cacheKey: _kCachePride,
      fetchedAtKey: _kFetchedPride,
      forceRefresh: forceRefresh,
    );
  }

  // =============================
  // Public API (Academic Calendar)
  // =============================

  Future<PcuAcademicCalendarResult> loadAcademicCalendar({bool forceRefresh = false}) async {
    final sp = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = sp.getString(_kCacheAcademicCalendar);
      final fetchedAtMs = sp.getInt(_kFetchedAcademicCalendar);
      if (cached != null && fetchedAtMs != null) {
        final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
        if (DateTime.now().difference(fetchedAt) <= cacheTtl) {
          return PcuAcademicCalendarResult.fromJson(
            jsonDecode(cached) as Map<String, dynamic>,
          );
        }
      }
    }

    final resp = await http.get(Uri.parse(academicCalendarUrl));
    if (resp.statusCode != 200) {
      final cached = sp.getString(_kCacheAcademicCalendar);
      if (cached != null) {
        return PcuAcademicCalendarResult.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }
      throw Exception('학사일정 페이지 로드 실패: ${resp.statusCode}');
    }

    final result = _parseAcademicCalendar(resp.body);

    await sp.setString(_kCacheAcademicCalendar, jsonEncode(result.toJson()));
    await sp.setInt(_kFetchedAcademicCalendar, DateTime.now().millisecondsSinceEpoch);

    return result;
  }

  // =============================
  // Core load helpers
  // =============================

  Future<PcuPageDoc> _loadDoc({
    required String url,
    required String cacheKey,
    required String fetchedAtKey,
    required PcuPageDoc Function(String htmlText, String url) parser,
    required bool forceRefresh,
  }) async {
    final sp = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = sp.getString(cacheKey);
      final fetchedAtMs = sp.getInt(fetchedAtKey);
      if (cached != null && fetchedAtMs != null) {
        final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
        if (DateTime.now().difference(fetchedAt) <= cacheTtl) {
          return PcuPageDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      final cached = sp.getString(cacheKey);
      if (cached != null) {
        return PcuPageDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      throw Exception('페이지 로드 실패($url): ${resp.statusCode}');
    }

    final doc = parser(resp.body, url);
    await sp.setString(cacheKey, jsonEncode(doc.toJson()));
    await sp.setInt(fetchedAtKey, DateTime.now().millisecondsSinceEpoch);
    return doc;
  }

  Future<PcuTimelineDoc> _loadTimeline({
    required String url,
    required String cacheKey,
    required String fetchedAtKey,
    required bool forceRefresh,
  }) async {
    final sp = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = sp.getString(cacheKey);
      final fetchedAtMs = sp.getInt(fetchedAtKey);
      if (cached != null && fetchedAtMs != null) {
        final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
        if (DateTime.now().difference(fetchedAt) <= cacheTtl) {
          return PcuTimelineDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      final cached = sp.getString(cacheKey);
      if (cached != null) {
        return PcuTimelineDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      throw Exception('페이지 로드 실패($url): ${resp.statusCode}');
    }

    final doc = _parseTimeline(resp.body, url);
    await sp.setString(cacheKey, jsonEncode(doc.toJson()));
    await sp.setInt(fetchedAtKey, DateTime.now().millisecondsSinceEpoch);
    return doc;
  }

  Future<PcuPrideDoc> _loadPride({
    required String url,
    required String cacheKey,
    required String fetchedAtKey,
    required bool forceRefresh,
  }) async {
    final sp = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = sp.getString(cacheKey);
      final fetchedAtMs = sp.getInt(fetchedAtKey);
      if (cached != null && fetchedAtMs != null) {
        final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
        if (DateTime.now().difference(fetchedAt) <= cacheTtl) {
          return PcuPrideDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        }
      }
    }

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      final cached = sp.getString(cacheKey);
      if (cached != null) {
        return PcuPrideDoc.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      }
      throw Exception('페이지 로드 실패($url): ${resp.statusCode}');
    }

    final doc = _parsePride(resp.body, url);
    await sp.setString(cacheKey, jsonEncode(doc.toJson()));
    await sp.setInt(fetchedAtKey, DateTime.now().millisecondsSinceEpoch);
    return doc;
  }

  // =============================
  // Parsers (4 Tabs)
  // =============================

  PcuPageDoc _parseGenericDocWithHeadings(String htmlText, String url) {
    final doc = html.parse(htmlText);

    final candidates = doc.querySelectorAll('div');
    Element? best;
    int bestLen = 0;
    for (final c in candidates) {
      final t = _cleanText(c.text);
      if (t.length > bestLen) {
        bestLen = t.length;
        best = c;
      }
    }
    final root = best ?? doc.body;

    if (root == null) {
      return PcuPageDoc(sourceUrl: url, title: '', sections: const [], note: '본문 탐지 실패');
    }

    String title = '';
    for (final tag in ['h2', 'h3', 'h4']) {
      final h = root.querySelector(tag);
      if (h != null) {
        title = _cleanText(h.text);
        if (title.isNotEmpty) break;
      }
    }

    final sections = <PcuTextSection>[];
    final h4s = root.querySelectorAll('h4');

    if (h4s.isEmpty) {
      final plain = _extractPlainLines(root.text);
      return PcuPageDoc(
        sourceUrl: url,
        title: title,
        sections: [
          PcuTextSection(heading: title.isEmpty ? '내용' : title, lines: plain.take(120).toList()),
        ],
        note: null,
      );
    }

    for (final h in h4s) {
      final heading = _cleanText(h.text);
      if (heading.isEmpty) continue;

      final lines = <String>[];
      Element? cursor = h.nextElementSibling;

      while (cursor != null && cursor.localName != 'h4') {
        final all = _cleanText(cursor.text);
        if (all.contains('콘텐츠 정보') || all.contains('담당부서') || all.contains('최종수정일')) break;

        final name = cursor.localName ?? '';
        if (name == 'p') {
          final t = _cleanText(cursor.text);
          if (t.isNotEmpty) lines.add(t);
        } else if (name == 'ul' || name == 'ol') {
          for (final li in cursor.querySelectorAll('li')) {
            final t = _cleanText(li.text);
            if (t.isNotEmpty) lines.add('• $t');
          }
        } else {
          for (final li in cursor.querySelectorAll('li')) {
            final t = _cleanText(li.text);
            if (t.isNotEmpty) lines.add('• $t');
          }
          if ((cursor.querySelectorAll('li')).isEmpty) {
            final t = _cleanText(cursor.text);
            if (t.isNotEmpty && t.length <= 220) lines.add(t);
          }
        }

        cursor = cursor.nextElementSibling;
      }

      final cleaned = _dedup(lines);
      if (cleaned.isNotEmpty) {
        sections.add(PcuTextSection(heading: heading, lines: cleaned));
      }
    }

    if (sections.isEmpty) {
      final plain = _extractPlainLines(root.text);
      sections.add(PcuTextSection(
          heading: title.isEmpty ? '내용' : title, lines: plain.take(120).toList()));
    }

    return PcuPageDoc(sourceUrl: url, title: title, sections: sections, note: null);
  }

  PcuTimelineDoc _parseTimeline(String htmlText, String url) {
    final doc = html.parse(htmlText);
    final lines = (doc.body?.text ?? '')
        .replaceAll('\u00A0', ' ')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final startIdx = lines.indexWhere((l) => l.contains('연혁'));
    final begin = startIdx >= 0 ? startIdx : 0;

    bool isYear(String s) => RegExp(r'^\d{4}$').hasMatch(s);
    bool isDate(String s) {
      final x = s.replaceAll(' ', '');
      return RegExp(r'^\d{1,2}\.\d{1,2}\.?$').hasMatch(x);
    }

    final items = <PcuTimelineItem>[];
    String? curYear;
    String? curDate;

    for (int i = begin; i < lines.length; i++) {
      final l = lines[i];
      if (l.contains('콘텐츠 정보') || l.contains('담당부서') || l.contains('최종수정일')) break;

      if (isYear(l)) {
        curYear = l;
        curDate = null;
        continue;
      }
      if (isDate(l)) {
        curDate = l.replaceAll(' ', '');
        continue;
      }

      if (curYear != null && curDate != null) {
        if (l.length <= 2) continue;
        items.add(PcuTimelineItem(year: curYear, dateText: curDate, title: l, notes: const []));
      }
    }

    return PcuTimelineDoc(
      sourceUrl: url,
      title: '연혁',
      items: items,
      note: items.isEmpty ? '연혁 파싱 결과가 비어있어요(페이지 구조 변경 가능)' : null,
    );
  }

  PcuPrideDoc _parsePride(String htmlText, String url) {
    final doc = html.parse(htmlText);
    final lines = (doc.body?.text ?? '')
        .replaceAll('\u00A0', ' ')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final startIdx = lines.indexWhere((l) => l.contains('PCU PRIDE'));
    final begin = startIdx >= 0 ? startIdx : 0;

    final items = <PcuPrideItem>[];
    final yearRe = RegExp(r'^(19|20)\d{2}(\s*-\s*(19|20)\d{2})?');

    for (int i = begin; i < lines.length; i++) {
      final l = lines[i];
      if (l.contains('콘텐츠 정보') || l.contains('담당부서') || l.contains('최종수정일')) break;

      if (yearRe.hasMatch(l)) {
        final full = l;
        final parts = full
            .split(RegExp(r'\s{2,}|  '))
            .where((e) => e.trim().isNotEmpty)
            .toList();
        String text = full;
        String? org;
        if (parts.length >= 2) {
          text = parts.first.trim();
          org = parts.sublist(1).join(' ').trim();
        }
        items.add(PcuPrideItem(text: text, org: org));
      }
    }

    if (items.length < 5) {
      for (final l in lines) {
        if (yearRe.hasMatch(l)) items.add(PcuPrideItem(text: l, org: null));
      }
    }

    final uniq = <String>{};
    final cleaned = <PcuPrideItem>[];
    for (final it in items) {
      final key = '${it.text}|${it.org ?? ''}';
      if (uniq.add(key)) cleaned.add(it);
    }

    return PcuPrideDoc(
      sourceUrl: url,
      title: 'PCU PRIDE',
      items: cleaned,
      note: cleaned.isEmpty ? 'PCU PRIDE 파싱 결과가 비어있어요(페이지 구조 변경 가능)' : null,
    );
  }

  // =============================
  // Parser (Academic Calendar)
  // =============================

  PcuAcademicCalendarResult _parseAcademicCalendar(String htmlText) {
    final doc = html.parse(htmlText);
    final lines = (doc.body?.text ?? '')
        .replaceAll('\u00A0', ' ')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    int baseYear = DateTime.now().year;
    final hit = lines.firstWhere(
          (l) => RegExp(r'^\d{4}-[12]학기').hasMatch(l) || RegExp(r'\d{4}-[12]학기').hasMatch(l),
      orElse: () => '',
    );
    final m = RegExp(r'(\d{4})-').firstMatch(hit);
    if (m != null) baseYear = int.parse(m.group(1) ?? '$baseYear');

    final events = <PcuCalendarEvent>[];
    final dateRe = RegExp(r'^(\d{2})-(\d{2})(?:~(\d{2})-(\d{2}))?일$');

    int? currentMonthSeen;
    int currentYear = baseYear;

    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (l.contains('콘텐츠 정보') || l.contains('담당부서') || l.contains('최종수정일')) break;

      final dm = dateRe.firstMatch(l);
      if (dm == null) continue;

      final sm = int.parse(dm.group(1)!);
      final sd = int.parse(dm.group(2)!);
      final em = dm.group(3) != null ? int.parse(dm.group(3)!) : null;
      final ed = dm.group(4) != null ? int.parse(dm.group(4)!) : null;

      if (currentMonthSeen != null && sm < currentMonthSeen) currentYear += 1;
      currentMonthSeen = sm;

      String title = '';
      if (i + 1 < lines.length) {
        final next = lines[i + 1];
        title = next.startsWith('*') ? next.replaceFirst('*', '').trim() : next;
      }

      final start = DateTime(currentYear, sm, sd);
      DateTime? end;
      if (em != null && ed != null) {
        final endYear = (em < sm) ? (currentYear + 1) : currentYear;
        end = DateTime(endYear, em, ed);
      }

      final dateText = end == null ? _fmt(start) : '${_fmt(start)} ~ ${_fmt(end)}';

      events.add(
        PcuCalendarEvent(
          title: title.isEmpty ? '(제목 파싱 실패)' : title,
          dateText: dateText,
          startIso: _fmtIso(start),
          endIso: end != null ? _fmtIso(end) : null,
          category: _guessCalendarCategory(title),
        ),
      );
    }

    final note = events.length < 10 ? '파싱 결과가 너무 적습니다(HTML 구조 변경 가능).' : null;

    return PcuAcademicCalendarResult(
      sourceUrl: academicCalendarUrl,
      baseYear: baseYear,
      events: events,
      note: note,
    );
  }

  static PcuCalendarCategory _guessCalendarCategory(String title) {
    final t = title.replaceAll(' ', '');
    bool hasAny(List<String> keys) => keys.any((k) => t.contains(k));

    if (hasAny(['수강신청', '계절학기', '개강', '종강'])) return PcuCalendarCategory.course;
    if (hasAny(['수강신청변경', '수강철회', '수강정정'])) return PcuCalendarCategory.courseChange;
    if (hasAny(['중간고사', '학기말고사', '기말고사', '시험'])) return PcuCalendarCategory.exam;
    if (hasAny(['성적', '이의신청', '성적입력', '성적공람'])) return PcuCalendarCategory.grade;
    if (hasAny(['등록'])) return PcuCalendarCategory.register;
    if (hasAny(['휴학', '복학', '전부', '복수', '부전공', '연계', '융합', 'MD', '조기졸업', '취득유예', '학위'])) {
      return PcuCalendarCategory.admin;
    }
    if (hasAny(['공휴일','연휴','대체휴일','휴업','신정','추석','설','광복절','한글날','개천절','현충일','성탄절','어린이날'])) {
      return PcuCalendarCategory.holiday;
    }
    if (hasAny(['수업일수', '보충', '학기시작'])) return PcuCalendarCategory.semester;
    return PcuCalendarCategory.event;
  }

  // =============================
  // Utils
  // =============================

  static String _cleanText(String s) {
    var x = s.replaceAll('\u00A0', ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

  static List<String> _extractPlainLines(String s) {
    final raw = s.replaceAll('\u00A0', ' ');
    final parts = raw.split(RegExp(r'\n+'));
    final lines = <String>[];
    for (final p in parts) {
      final t = _cleanText(p);
      if (t.isEmpty) continue;
      if (t.contains('콘텐츠 정보') || t.contains('담당부서') || t.contains('최종수정일')) break;
      lines.add(t);
    }
    return _dedup(lines);
  }

  static List<String> _dedup(List<String> xs) {
    final out = <String>[];
    final seen = <String>{};
    for (final x in xs) {
      final k = x.trim();
      if (k.isEmpty) continue;
      if (seen.add(k)) out.add(k);
    }
    return out;
  }

  static String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  static String _fmtIso(DateTime d) => _fmt(d);
}

// ==========================
// Models (Tabs)
// ==========================

class PcuTextSection {
  final String heading;
  final List<String> lines;

  const PcuTextSection({required this.heading, required this.lines});

  Map<String, dynamic> toJson() => {'heading': heading, 'lines': lines};

  static PcuTextSection fromJson(Map<String, dynamic> j) => PcuTextSection(
    heading: j['heading'] as String,
    lines: (j['lines'] as List).map((e) => e.toString()).toList(),
  );
}

class PcuPageDoc {
  final String sourceUrl;
  final String title;
  final List<PcuTextSection> sections;
  final String? note;

  const PcuPageDoc({
    required this.sourceUrl,
    required this.title,
    required this.sections,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'sourceUrl': sourceUrl,
    'title': title,
    'sections': sections.map((e) => e.toJson()).toList(),
    'note': note,
  };

  static PcuPageDoc fromJson(Map<String, dynamic> j) => PcuPageDoc(
    sourceUrl: j['sourceUrl'] as String,
    title: j['title'] as String,
    sections: (j['sections'] as List)
        .map((e) => PcuTextSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    note: j['note'] as String?,
  );
}

class PcuTimelineItem {
  final String year;
  final String dateText;
  final String title;
  final List<String> notes;

  const PcuTimelineItem({
    required this.year,
    required this.dateText,
    required this.title,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'year': year,
    'dateText': dateText,
    'title': title,
    'notes': notes,
  };

  static PcuTimelineItem fromJson(Map<String, dynamic> j) => PcuTimelineItem(
    year: j['year'] as String,
    dateText: j['dateText'] as String,
    title: j['title'] as String,
    notes: (j['notes'] as List).map((e) => e.toString()).toList(),
  );
}

class PcuTimelineDoc {
  final String sourceUrl;
  final String title;
  final List<PcuTimelineItem> items;
  final String? note;

  const PcuTimelineDoc({
    required this.sourceUrl,
    required this.title,
    required this.items,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'sourceUrl': sourceUrl,
    'title': title,
    'items': items.map((e) => e.toJson()).toList(),
    'note': note,
  };

  static PcuTimelineDoc fromJson(Map<String, dynamic> j) => PcuTimelineDoc(
    sourceUrl: j['sourceUrl'] as String,
    title: j['title'] as String,
    items: (j['items'] as List)
        .map((e) => PcuTimelineItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    note: j['note'] as String?,
  );
}

class PcuPrideItem {
  final String text;
  final String? org;

  const PcuPrideItem({required this.text, required this.org});

  Map<String, dynamic> toJson() => {'text': text, 'org': org};

  static PcuPrideItem fromJson(Map<String, dynamic> j) => PcuPrideItem(
    text: j['text'] as String,
    org: j['org'] as String?,
  );
}

class PcuPrideDoc {
  final String sourceUrl;
  final String title;
  final List<PcuPrideItem> items;
  final String? note;

  const PcuPrideDoc({
    required this.sourceUrl,
    required this.title,
    required this.items,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'sourceUrl': sourceUrl,
    'title': title,
    'items': items.map((e) => e.toJson()).toList(),
    'note': note,
  };

  static PcuPrideDoc fromJson(Map<String, dynamic> j) => PcuPrideDoc(
    sourceUrl: j['sourceUrl'] as String,
    title: j['title'] as String,
    items: (j['items'] as List)
        .map((e) => PcuPrideItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    note: j['note'] as String?,
  );
}

// ==========================
// Models (Academic Calendar)
// ==========================

enum PcuCalendarCategory { course, courseChange, exam, grade, register, admin, holiday, semester, event }

class PcuCalendarEvent {
  final String title;
  final String dateText;
  final String startIso;
  final String? endIso;
  final PcuCalendarCategory category;

  const PcuCalendarEvent({
    required this.title,
    required this.dateText,
    required this.startIso,
    required this.endIso,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'dateText': dateText,
    'startIso': startIso,
    'endIso': endIso,
    'category': category.name,
  };

  static PcuCalendarEvent fromJson(Map<String, dynamic> j) => PcuCalendarEvent(
    title: j['title'] as String,
    dateText: j['dateText'] as String,
    startIso: j['startIso'] as String,
    endIso: j['endIso'] as String?,
    category: PcuCalendarCategory.values.firstWhere(
          (c) => c.name == (j['category'] as String),
      orElse: () => PcuCalendarCategory.event,
    ),
  );
}

class PcuAcademicCalendarResult {
  final String sourceUrl;
  final int baseYear;
  final List<PcuCalendarEvent> events;
  final String? note;

  const PcuAcademicCalendarResult({
    required this.sourceUrl,
    required this.baseYear,
    required this.events,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
    'sourceUrl': sourceUrl,
    'baseYear': baseYear,
    'events': events.map((e) => e.toJson()).toList(),
    'note': note,
  };

  static PcuAcademicCalendarResult fromJson(Map<String, dynamic> j) => PcuAcademicCalendarResult(
    sourceUrl: j['sourceUrl'] as String,
    baseYear: (j['baseYear'] as num).toInt(),
    events: (j['events'] as List)
        .map((e) => PcuCalendarEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    note: j['note'] as String?,
  );
}