// lib/features/timetable/domain/lecture_meeting.dart
class LectureMeeting {
  /// 0=월 ... 4=금 (토/일 데이터가 들어오면 UI에서는 보통 스킵)
  final int dayIndex;

  /// minutes from 00:00
  final int startMin;
  final int endMin;

  /// 같은 과목이라도 회차별 강의실이 다른 케이스가 있어서 meeting 단위로 둠
  final String room;

  const LectureMeeting({
    required this.dayIndex,
    required this.startMin,
    required this.endMin,
    required this.room,
  });

  @override
  String toString() => 'LectureMeeting(day=$dayIndex $startMin~$endMin room=$room)';
}