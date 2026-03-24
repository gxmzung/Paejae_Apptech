// lib/features/timetable/domain/lecture_row.dart
import 'lecture_meeting.dart';

class LectureRow {
  final String code;
  final String name;

  /// 전필/전선/교양 등 (이수구분)
  final String division;

  final String professor;

  /// 원본 셀 값 그대로(디버깅용)
  final String roomTimeRaw;

  /// 화면 표시용(대표 강의실)
  final String room;

  /// fallback 표시용
  final String day;
  final String time;

  /// ✅ 가장 중요: 실제 시간표 렌더링은 meetings 기준
  final List<LectureMeeting> meetings;

  const LectureRow({
    required this.code,
    required this.name,
    required this.division,
    required this.professor,
    required this.roomTimeRaw,
    required this.room,
    required this.day,
    required this.time,
    required this.meetings,
  });

  // ============================================================
  // ✅ legacy compatibility (기존 파일들이 section/timeRaw를 참조)
  // ============================================================

  /// 예전 코드들이 분반(section)을 쓰던 흔적.
  /// 지금 엑셀/모델에 분반이 없으니 "빈 문자열"이 가장 안전함.
  String get section => '';

  /// 예전 코드들이 timeRaw를 쓰던 흔적.
  /// 지금은 roomTimeRaw가 원본 셀이므로 그대로 alias.
  String get timeRaw => roomTimeRaw;
}