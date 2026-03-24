import 'package:flutter/material.dart';

/// 로드맵 한 줄 체크(할 일)
class RoadmapStep {
  final String title;
  final String? note; // 짧은 설명
  final IconData icon;
  final int priority; // 1(낮) ~ 5(높)

  const RoadmapStep({
    required this.title,
    this.note,
    required this.icon,
    this.priority = 3,
  });
}

/// 학기(또는 구간) 로드맵
class SemesterRoadmap {
  final String label; // 예: "1학년 1학기", "방학", "2학년"
  final List<RoadmapStep> steps;

  const SemesterRoadmap({
    required this.label,
    required this.steps,
  });
}

/// 전과/진로 로드맵(학과별)
class DeptRoadmap {
  final String deptId; // DeptInfo.id 와 동일
  final String title; // 화면 헤더
  final String subtitle; // 한 줄 요약
  final bool transferOpen; // 전과 가능 여부(배재대는 true 컨셉)

  /// 추천 전과 후보(같은 계열/연관 전공)
  final List<String> suggestedTransfers;

  /// 전체 로드맵(학기/구간별)
  final List<SemesterRoadmap> timeline;

  /// 추가 팁/주의사항
  final List<String> tips;

  const DeptRoadmap({
    required this.deptId,
    required this.title,
    required this.subtitle,
    required this.transferOpen,
    required this.suggestedTransfers,
    required this.timeline,
    required this.tips,
  });
}
