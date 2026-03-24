import 'lecture_meeting.dart';

class LectureParse {
  static const _days = ['월', '화', '수', '목', '금', '토', '일'];

  static int dayIndexOfKor(String dayKor) {
    return _days.indexOf(dayKor); // 못 찾으면 -1
  }

  /// (교시 -> 시간) 매핑
  /// 1교시 09:00~09:50, 2교시 10:00~10:50 ... (stride 60)
  static (int startMin, int endMin)? minutesFromPeriod(int period) {
    if (period <= 0 || period > 20) return null;
    final start = (9 + (period - 1)) * 60;
    final end = start + 50;
    return (start, end);
  }

  /// WeekGrid fallback에서 쓰는 helper: "09:00~10:15" 같은 범위를 파싱
  static (int, int)? tryParseTimeRangeToMinutes(String raw) => _parseTimeRangeToMinutes(raw);

  /// WeekGrid fallback에서 쓰는 helper: "A" / "D" / "10" 같은 토큰을 교시로
  static int? tryParsePeriodToken(String token) => _periodFromToken(token);

  static int? _periodFromLetter(String s) {
    if (s.isEmpty) return null;
    final up = s.trim().toUpperCase();
    final code = up.codeUnitAt(0);
    if (code < 65 || code > 90) return null; // A-Z
    return (code - 65) + 1; // A=1
  }

  static (int, int)? _parseTimeRangeToMinutes(String raw) {
    final s = raw.replaceAll(' ', '');
    // 09:00~10:15 / 09:00-10:15
    final re1 = RegExp(r'(\d{1,2}):(\d{2})[~-](\d{1,2}):(\d{2})');
    final m1 = re1.firstMatch(s);
    if (m1 != null) {
      final start = int.parse(m1.group(1)!) * 60 + int.parse(m1.group(2)!);
      final end = int.parse(m1.group(3)!) * 60 + int.parse(m1.group(4)!);
      if (end <= start) return null;
      return (start, end);
    }

    // 0900~1015 / 0900-1015
    final re2 = RegExp(r'(\d{2})(\d{2})[~-](\d{2})(\d{2})');
    final m2 = re2.firstMatch(s);
    if (m2 != null) {
      final start = int.parse(m2.group(1)!) * 60 + int.parse(m2.group(2)!);
      final end = int.parse(m2.group(3)!) * 60 + int.parse(m2.group(4)!);
      if (end <= start) return null;
      return (start, end);
    }

    return null;
  }

  static int? _periodFromToken(String token) {
    final t = token.trim();
    if (t.isEmpty) return null;

    // 숫자 교시
    final n = int.tryParse(t);
    if (n != null) return n;

    // 문자 교시
    return _periodFromLetter(t);
  }

  /// "강의실/강의시간" 셀 전체를 meetings로 파싱
  ///
  /// 지원 예:
  /// - "W306(수,A), W306(수,B)"
  /// - "W309(월D), W309(월E)"
  /// - "P307(수10)"
  /// - "W416(월E), W416(수E)"
  /// - "W310(화B), W310(목C)"
  static List<LectureMeeting> parseMeetingsFromRoomTimeCell(String raw) {
    final src = raw.trim();
    if (src.isEmpty) return const [];

    // 쉼표/줄바꿈/슬래시 등으로 분리
    final parts = src
        .split(RegExp(r'[,\n/]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final out = <LectureMeeting>[];

    for (final p0 in parts) {
      final p = p0.trim();
      if (p.isEmpty) continue;

      // ✅ 핵심: "마지막 ( ... )" 를 inside로 취급한다.
      // 예) C105(new)(수7)  -> room="C105(new)" inside="수7"
      // 예) W306(수,A)      -> room="W306"      inside="수,A"
      // 예) P307(수10)      -> room="P307"      inside="수10"
      final lastL = p.lastIndexOf('(');
      final lastR = p.lastIndexOf(')');

      String room;
      String inside;

      if (lastL >= 0 && lastR > lastL) {
        room = p.substring(0, lastL).trim();
        inside = p.substring(lastL + 1, lastR).trim();
      } else {
        // 괄호가 없으면 inline day/time을 기대해본다 (ex: "월 09:00~10:15")
        room = p;
        inside = '';
      }

      if (inside.isEmpty) {
        final inferred = _parseInlineDayTime(p);
        if (inferred != null) out.add(inferred);
        continue;
      }

      final parsed = _parseInside(room: room, inside: inside);
      if (parsed != null) out.addAll(parsed);
    }

    // 정렬(안정)
    out.sort((a, b) {
      final d = a.dayIndex.compareTo(b.dayIndex);
      if (d != 0) return d;
      return a.startMin.compareTo(b.startMin);
    });

    return out;
  }

  static LectureMeeting? _parseInlineDayTime(String s) {
    // ex) "월 09:00~10:15"
    final m = RegExp(r'([월화수목금토일])\s*(.+)$').firstMatch(s);
    if (m == null) return null;
    final day = m.group(1)!;
    final rest = m.group(2)!;
    final di = dayIndexOfKor(day);
    if (di < 0) return null;
    final tr = _parseTimeRangeToMinutes(rest);
    if (tr == null) return null;
    return LectureMeeting(dayIndex: di, startMin: tr.$1, endMin: tr.$2, room: '');
  }

  static List<LectureMeeting>? _parseInside({
    required String room,
    required String inside,
  }) {
    final x = inside.replaceAll(' ', '');

    final dayM = RegExp(r'^([월화수목금토일])').firstMatch(x);
    if (dayM == null) return null;

    final dayKor = dayM.group(1)!;
    final di = dayIndexOfKor(dayKor);
    if (di < 0) return null;

    var rest = x.substring(dayKor.length);
    rest = rest.replaceAll(RegExp(r'^[,·]+'), '');

    // 시간범위 "(수,09:00~10:15)"
    final timeRange = _parseTimeRangeToMinutes(rest);
    if (timeRange != null) {
      return [
        LectureMeeting(dayIndex: di, startMin: timeRange.$1, endMin: timeRange.$2, room: room)
      ];
    }

    // 교시 범위 "D~E", "3-4"
    final rangeM = RegExp(r'^([A-Za-z]|\d{1,2})[~-]([A-Za-z]|\d{1,2})$').firstMatch(rest);
    if (rangeM != null) {
      final a = rangeM.group(1)!;
      final b = rangeM.group(2)!;
      final pa = _periodFromToken(a);
      final pb = _periodFromToken(b);
      if (pa == null || pb == null) return null;

      final startP = pa < pb ? pa : pb;
      final endP = pa < pb ? pb : pa;

      final st = minutesFromPeriod(startP);
      final ed = minutesFromPeriod(endP);
      if (st == null || ed == null) return null;

      return [
        LectureMeeting(dayIndex: di, startMin: st.$1, endMin: ed.$2, room: room),
      ];
    }

    // 단일 교시: "A", "10", "D"
    final p = _periodFromToken(rest);
    if (p != null) {
      final tt = minutesFromPeriod(p);
      if (tt == null) return null;
      return [LectureMeeting(dayIndex: di, startMin: tt.$1, endMin: tt.$2, room: room)];
    }

    return null;
  }
}