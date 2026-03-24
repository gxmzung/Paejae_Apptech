// lib/timetable/timetable_data_mock.dart
import 'package:flutter/material.dart';
import 'timetable_models.dart';

class TimetableMock {
  static List<Course> sampleCourses() {
    return [
      Course(
        id: 'c1',
        name: '컴퓨팅사고',
        professor: '김교수',
        credit: 3,
        location: '공학관 302',
        color: const Color(0xFF2F6BFF),
        slots: const [
          CourseSlot(
              day: WeekdayKR.mon,
              startHour: 10,
              startMinute: 30,
              endHour: 12,
              endMinute: 0),
          CourseSlot(
              day: WeekdayKR.wed,
              startHour: 10,
              startMinute: 30,
              endHour: 12,
              endMinute: 0),
        ],
      ),
      Course(
        id: 'c2',
        name: '기초프로그래밍',
        professor: '박교수',
        credit: 3,
        location: '공학관 210',
        color: const Color(0xFF00A884),
        slots: const [
          CourseSlot(
              day: WeekdayKR.tue,
              startHour: 13,
              startMinute: 0,
              endHour: 14,
              endMinute: 30),
          CourseSlot(
              day: WeekdayKR.thu,
              startHour: 13,
              startMinute: 0,
              endHour: 14,
              endMinute: 30),
        ],
      ),
      Course(
        id: 'c3',
        name: '대학글쓰기',
        professor: '이교수',
        credit: 2,
        location: '인문관 101',
        color: const Color(0xFF7C4DFF),
        slots: const [
          CourseSlot(
              day: WeekdayKR.fri,
              startHour: 9,
              startMinute: 0,
              endHour: 10,
              endMinute: 30),
        ],
      ),
      Course(
        id: 'c4',
        name: '일반물리',
        professor: '최교수',
        credit: 3,
        location: '과학관 201',
        color: const Color(0xFFFF6D00),
        slots: const [
          CourseSlot(
              day: WeekdayKR.mon,
              startHour: 13,
              startMinute: 0,
              endHour: 14,
              endMinute: 30),
          CourseSlot(
              day: WeekdayKR.wed,
              startHour: 13,
              startMinute: 0,
              endHour: 14,
              endMinute: 30),
        ],
      ),
    ];
  }
}
