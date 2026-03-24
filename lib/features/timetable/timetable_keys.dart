import 'package:apptech_flutter/features/timetable/domain/lecture_row.dart';

/// ✅ SharedPreferences key (장바구니 저장)
const String kTimetableCartKey = 'timetable_cart_v3';

/// ✅ 과목을 유니크하게 식별하는 key
String lectureKeyOf(LectureRow r) {
  String norm(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');

  final code = norm(r.code);
  final name = norm(r.name);
  final prof = norm(r.professor);

  // roomTimeRaw가 가장 강력한 구분자
  final raw = norm(
    r.roomTimeRaw.isNotEmpty ? r.roomTimeRaw : '${r.room}|${r.day}|${r.time}',
  );

  return 'C:$code|N:$name|P:$prof|R:$raw';
}