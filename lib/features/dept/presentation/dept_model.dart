import 'package:flutter/material.dart';

/// 학과 분류
enum DeptCategory {
  humanitiesSocial,
  businessTourism,
  bioHealth,
  engineering,
  architecture,
  artDesign,
  generalCenter,
}

/// DeptCategory UI helpers (label / icon)
extension DeptCategoryX on DeptCategory {
  String get label {
    switch (this) {
      case DeptCategory.humanitiesSocial:
        return '인문사회';
      case DeptCategory.businessTourism:
        return '경영·관광';
      case DeptCategory.bioHealth:
        return '생명·보건';
      case DeptCategory.engineering:
        return '공학';
      case DeptCategory.architecture:
        return '건축';
      case DeptCategory.artDesign:
        return '예술·디자인';
      case DeptCategory.generalCenter:
        return '교양·센터';
    }
  }

  IconData get icon {
    switch (this) {
      case DeptCategory.humanitiesSocial:
        return Icons.menu_book_rounded;
      case DeptCategory.businessTourism:
        return Icons.storefront_rounded;
      case DeptCategory.bioHealth:
        return Icons.health_and_safety_rounded;
      case DeptCategory.engineering:
        return Icons.memory_rounded;
      case DeptCategory.architecture:
        return Icons.apartment_rounded;
      case DeptCategory.artDesign:
        return Icons.brush_rounded;
      case DeptCategory.generalCenter:
        return Icons.hub_rounded;
    }
  }
}

/// 난이도
class DeptDifficulty {
  final int level; // 1~5
  final String comment;

  const DeptDifficulty({
    required this.level,
    required this.comment,
  });
}

/// 전과/복전/부전공 옵션
class DeptOptions {
  final bool transfer; // 전과
  final bool doubleMajor; // 복수전공
  final bool minor; // 부전공
  final String note;

  const DeptOptions({
    required this.transfer,
    required this.doubleMajor,
    required this.minor,
    required this.note,
  });
}

/// 학과 정보 모델
class DeptInfo {
  // ===== 기존 =====
  final String id;
  final String name;
  final DeptCategory category;
  final String mascotAsset; // 이미지 경로
  final List<String> tags;
  final List<String> intro5;
  final List<String> careers;

  // ===== 신규 (옵션: 없어도 동작하도록 nullable) =====
  final List<String>? learnWhat; // 뭐 배우지?
  final DeptDifficulty? difficulty; // 난이도
  final List<String>? jobs; // 취업
  final DeptOptions? options; // 전과/복전/부전공
  final List<String>? culture; // 분위기

  const DeptInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.mascotAsset,
    required this.tags,
    required this.intro5,
    required this.careers,
    this.learnWhat,
    this.difficulty,
    this.jobs,
    this.options,
    this.culture,
  });
}