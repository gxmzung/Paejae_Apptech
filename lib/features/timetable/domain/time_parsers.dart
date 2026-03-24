// lib/features/timetable/domain/time_parsers.dart
class ParsedMeeting {
  final int dayIndex; // 0=월..4=금
  final int startMin;
  final int endMin;

  const ParsedMeeting({
    required this.dayIndex,
    required this.startMin,
    required this.endMin,
  });
}

class TimetableParsers {
  static const _days = ['월', '화', '수', '목', '금'];

  static List<int> parseDays(String rawDayOrMixed) {
    final s = rawDayOrMixed.replaceAll(' ', '');
    if (s.isEmpty) return const [];

    final out = <int>[];
    for (int i = 0; i < _days.length; i++) {
      if (s.contains(_days[i])) out.add(i);
    }
    return out;
  }

  static (int, int)? parseTimeRangeToMinutes(String raw) {
    final s = raw.replaceAll(' ', '');

    // 1) HH:MM~HH:MM or HH:MM-HH:MM
    final re = RegExp(r'(\d{1,2}):(\d{2})[~-](\d{1,2}):(\d{2})');
    final m = re.firstMatch(s);
    if (m != null) {
      final start = int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
      final end   = int.parse(m.group(3)!) * 60 + int.parse(m.group(4)!);
      if (end > start) return (start, end);
    }

    // 2) 교시: 1-2교시
    final p = RegExp(r'(\d+)[~-](\d+)교시').firstMatch(s);
    if (p != null) {
      final p1 = int.parse(p.group(1)!);
      final p2 = int.parse(p.group(2)!);
      final t1 = _periodToMinutes[p1];
      final t2 = _periodToMinutes[p2];
      if (t1 != null && t2 != null) return (t1.$1, t2.$2);
    }

    // 3) 단일 교시: 3교시
    final pSingle = RegExp(r'(\d+)교시').firstMatch(s);
    if (pSingle != null) {
      final p1 = int.parse(pSingle.group(1)!);
      final t1 = _periodToMinutes[p1];
      if (t1 != null) return (t1.$1, t1.$2);
    }

    return null;
  }

  static List<ParsedMeeting> explodeMeetings({
    required String day,
    required String time,
  }) {
    // day/time이 섞여있는 경우도 있으니 합쳐서 한번 더 탐색
    final mixed = '$day $time';

    final days = parseDays(mixed);
    final tr = parseTimeRangeToMinutes(mixed);

    if (days.isEmpty || tr == null) return const [];
    final (start, end) = tr;

    return days
        .map((d) => ParsedMeeting(dayIndex: d, startMin: start, endMin: end))
        .toList();
  }

  static const Map<int, (int, int)> _periodToMinutes = {
    1: (9 * 60, 9 * 60 + 50),
    2: (10 * 60, 10 * 60 + 50),
    3: (11 * 60, 11 * 60 + 50),
    4: (12 * 60, 12 * 60 + 50),
    5: (13 * 60, 13 * 60 + 50),
    6: (14 * 60, 14 * 60 + 50),
    7: (15 * 60, 15 * 60 + 50),
    8: (16 * 60, 16 * 60 + 50),
    9: (17 * 60, 17 * 60 + 50),
    10: (18 * 60, 18 * 60 + 50),
  };
}