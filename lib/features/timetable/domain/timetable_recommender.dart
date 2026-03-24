import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/features/timetable/data/lecture_xlsx_loader.dart';
import 'lecture_row.dart';

/// ✅ 홈(HomeScreen)에서 쓰는 cart 키와 동일해야 함
const String kTimetableCartKey = 'timetable_cart_v1';

/// ✅ 너 HomeScreen에 있던 keyOf 로직과 "완전히 동일"하게 맞춤
String timetableKeyOf(LectureRow x) {
  final code = x.code.trim();
  final div = x.division.trim();
  final name = x.name.trim();
  if (code.isNotEmpty) return 'C:$code|D:$div|N:$name';
  return 'N:$name|P:${x.professor.trim()}|T:${x.timeRaw.trim()}';
}

/// 과목을 찾기 위한 매칭 조건
class CourseMatch {
  final String? code;      // 예: AIS22101
  final String? nameLike;  // 예: 기초C프로그래밍
  const CourseMatch({this.code, this.nameLike});
}

/// 추천 템플릿(학과/학년/학기)
class TimetablePreset {
  final String dept;
  final String grade;     // '1학년' 같은 문자열
  final int semester;     // 1 or 2
  final List<CourseMatch> courses;

  const TimetablePreset({
    required this.dept,
    required this.grade,
    required this.semester,
    required this.courses,
  });
}

class TimetableRecommender {
  TimetableRecommender._();

  /// ✅ 학교가 짜준 1학기(컴퓨터공학전공 1학년 1학기) 이미지 기반 템플릿
  /// - 컴퓨팅사고(06) (화 3-4 / 수 5-6)
  /// - 기초C프로그래밍(07) (화 5-8)
  /// - 전공의이해(10) (수 7)
  /// - 기초웹프로그래밍(05) (목 5-8)
  /// - 채플1(02) (금 6)
  /// - 온라인: 혁신교육과미래설계(10), AI이해및활용(04)
  static const TimetablePreset pcuCseFreshmanSem1 = TimetablePreset(
    dept: '컴퓨터공학전공(소프트웨어공학부)',
    grade: '1학년',
    semester: 1,
    courses: [
      // 코드가 엑셀에 있으면 코드 우선 매칭
      CourseMatch(code: 'PAIS2501', nameLike: '컴퓨팅사고'),
      CourseMatch(code: 'AIS22101', nameLike: '기초C프로그래밍'),
      CourseMatch(code: 'AIS22103', nameLike: '전공의이해'),
      CourseMatch(code: 'COM22101', nameLike: '기초웹프로그래밍'),
      // 아래는 엑셀 코드가 다를 수 있어 nameLike로도 잡힘
      CourseMatch(nameLike: '채플'),
      CourseMatch(nameLike: '혁신교육과미래설계'),
      CourseMatch(nameLike: 'AI이해및활용'),
    ],
  );

  /// 현재 프로필(학과/학년/학기)로 프리셋 선택
  static TimetablePreset? pickPreset({
    required String dept,
    required String grade,
    required int semester,
  }) {
    final d = dept.trim();
    final g = grade.trim();
    if (d == pcuCseFreshmanSem1.dept && g == pcuCseFreshmanSem1.grade && semester == 1) {
      return pcuCseFreshmanSem1;
    }
    return null;
  }

  /// 엑셀 로드 후, 프리셋 과목을 LectureRow로 찾아서 반환
  static Future<List<LectureRow>> buildRecommendedRows(TimetablePreset preset) async {
    final all = await LectureXlsxLoader.loadFromAsset('assets/data/lectures.xlsx');

    LectureRow? byCode(String code) {
      final c = code.trim();
      if (c.isEmpty) return null;
      for (final x in all) {
        if (x.code.trim() == c) return x;
      }
      return null;
    }

    LectureRow? byNameLike(String nameLike) {
      final q = nameLike.trim();
      if (q.isEmpty) return null;
      for (final x in all) {
        if (x.name.contains(q)) return x;
      }
      return null;
    }

    final picked = <LectureRow>[];
    final usedKeys = <String>{};

    for (final m in preset.courses) {
      LectureRow? row;
      if (m.code != null) row = byCode(m.code!);
      row ??= (m.nameLike != null ? byNameLike(m.nameLike!) : null);
      if (row == null) continue;

      final key = timetableKeyOf(row);
      if (usedKeys.add(key)) picked.add(row);
    }

    return picked;
  }

  /// ✅ 추천 시간표를 "장바구니(cart)"에 저장 (홈/시간표 화면이 그대로 읽게)
  static Future<void> applyPresetToCart(TimetablePreset preset) async {
    final rows = await buildRecommendedRows(preset);
    final keys = rows.map(timetableKeyOf).toList();

    final sp = await SharedPreferences.getInstance();
    await sp.setString(kTimetableCartKey, jsonEncode(keys));
  }
}