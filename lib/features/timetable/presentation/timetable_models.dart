// lib/timetable/timetable_models.dart
import 'package:flutter/material.dart';

enum WeekdayKR { mon, tue, wed, thu, fri }

extension WeekdayKRExt on WeekdayKR {
  String get label {
    switch (this) {
      case WeekdayKR.mon:
        return '월';
      case WeekdayKR.tue:
        return '화';
      case WeekdayKR.wed:
        return '수';
      case WeekdayKR.thu:
        return '목';
      case WeekdayKR.fri:
        return '금';
    }
  }

  int get index0 {
    switch (this) {
      case WeekdayKR.mon:
        return 0;
      case WeekdayKR.tue:
        return 1;
      case WeekdayKR.wed:
        return 2;
      case WeekdayKR.thu:
        return 3;
      case WeekdayKR.fri:
        return 4;
    }
  }
}

class Course {
  final String id;
  final String name;
  final String professor;
  final int credit;
  final String location;
  final Color color; // 일정 카드 색상
  final List<CourseSlot> slots;

  const Course({
    required this.id,
    required this.name,
    required this.professor,
    required this.credit,
    required this.location,
    required this.color,
    required this.slots,
  });
}

class CourseSlot {
  final WeekdayKR day;
  final int startHour; // 9~18 같은 정수시간
  final int startMinute; // 0 or 30 등
  final int endHour;
  final int endMinute;

  const CourseSlot({
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  int get startInMinutes => startHour * 60 + startMinute;
  int get endInMinutes => endHour * 60 + endMinute;
}

class TimetableBlock {
  final Course course;
  final CourseSlot slot;
  const TimetableBlock({required this.course, required this.slot});
}
