// lib/features/timetable/domain/timetable_conflict.dart
import 'lecture_row.dart';
import 'time_parsers.dart';

class ConflictResult {
  final bool hasConflict;
  final List<String> messages;

  const ConflictResult({required this.hasConflict, required this.messages});
}

class TimetableConflict {
  static ConflictResult check(List<LectureRow> picked) {
    final meetings = <({int day, int s, int e, String title, String code})>[];

    for (final r in picked) {
      final ms = TimetableParsers.explodeMeetings(day: r.day, time: r.time);
      for (final m in ms) {
        meetings.add((day: m.dayIndex, s: m.startMin, e: m.endMin, title: r.name, code: r.code));
      }
    }

    meetings.sort((a, b) {
      if (a.day != b.day) return a.day.compareTo(b.day);
      return a.s.compareTo(b.s);
    });

    final msgs = <String>[];
    for (int i = 0; i < meetings.length; i++) {
      for (int j = i + 1; j < meetings.length; j++) {
        final A = meetings[i];
        final B = meetings[j];
        if (A.day != B.day) break;
        final overlap = A.s < B.e && B.s < A.e;
        if (overlap) {
          msgs.add('겹침: ${A.title}(${A.code}) ↔ ${B.title}(${B.code})');
        }
      }
    }

    return ConflictResult(hasConflict: msgs.isNotEmpty, messages: msgs);
  }
}