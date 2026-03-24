import 'package:flutter/material.dart';
import 'dept_roadmap_model.dart';

final Map<String, DeptRoadmap> deptRoadmaps = {
  // =========================
  // ✅ 소프트웨어공학부(컴공) - 감정님 핵심
  // =========================
  'software_division': DeptRoadmap(
    deptId: 'software_division',
    title: '소프트웨어공학부 로드맵',
    subtitle: '전과 100% 가능 컨셉 · “포트폴리오로 뚫는” 루트',
    transferOpen: true,
    suggestedTransfers: const [
      '전기전자공학과',
      '드론로봇공학과',
      '스마트배터리학과',
      'IT경영정보학과',
    ],
    timeline: const [
      SemesterRoadmap(
        label: '1학년 1학기',
        steps: [
          RoadmapStep(
            title: '개발환경 고정 (Flutter/Android Studio/VSCode)',
            note: '툴 체인 고정 + 템플릿 프로젝트 1개 완성',
            icon: Icons.build_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: 'CS 기초(자료구조/알고리즘) 루틴 시작',
            note: '주 3회 30분이라도 꾸준히',
            icon: Icons.auto_graph_rounded,
            priority: 4,
          ),
          RoadmapStep(
            title: '앱 1개 “배포 가능한 상태” 만들기',
            note: '로그인/네비/상태관리/저장소까지',
            icon: Icons.rocket_launch_rounded,
            priority: 5,
          ),
        ],
      ),
      SemesterRoadmap(
        label: '1학년 1학기 방학',
        steps: [
          RoadmapStep(
            title: '포트폴리오 2개째(팀/캡스톤 대비)',
            note: 'API 연동 + 간단한 서버/DB까지',
            icon: Icons.layers_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: 'Git/GitHub 협업 플로우 익히기',
            note: 'PR/리뷰/이슈/릴리즈 태그',
            icon: Icons.merge_rounded,
            priority: 4,
          ),
        ],
      ),
      SemesterRoadmap(
        label: '2학년',
        steps: [
          RoadmapStep(
            title: '백엔드/DB 최소 1스택 붙이기',
            note: 'Firebase or Supabase or Spring 중 택1',
            icon: Icons.storage_rounded,
            priority: 4,
          ),
          RoadmapStep(
            title: 'AI 기능은 “UX에 녹여서” 1개만',
            note: '예: 요약/추천/분류 중 하나를 완성형으로',
            icon: Icons.smart_toy_rounded,
            priority: 3,
          ),
        ],
      ),
      SemesterRoadmap(
        label: '전과 루트(선택)',
        steps: [
          RoadmapStep(
            title: '전과 목표 학과의 “필수 과목/요구 역량” 확인',
            note: '필수 교과 + 포트폴리오로 증명',
            icon: Icons.fact_check_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: '전과용 증빙 포폴 1개 만들기',
            note: '예: 임베디드/회로/로봇 관련 기능을 앱과 연결',
            icon: Icons.workspace_premium_rounded,
            priority: 5,
          ),
        ],
      ),
    ],
    tips: const [
      '전과가 “가능”이어도, 설득 자료(학업 계획 + 결과물)가 있으면 압도적으로 유리해.',
      '“기능이 많음”보다 “1개 기능을 끝까지 완성”이 평가에 강함.',
      'PcuCamPus는 이미 강력한 포트폴리오라서, 남은 건 “운영 근거/지표/유지보수 구조”야.',
    ],
  ),

  // =========================
  // 전기전자공학과
  // =========================
  'ee': DeptRoadmap(
    deptId: 'ee',
    title: '전기전자공학과 로드맵',
    subtitle: '회로 → MCU/임베디드 → 프로젝트',
    transferOpen: true,
    suggestedTransfers: const ['소프트웨어공학부', '드론로봇공학과'],
    timeline: const [
      SemesterRoadmap(
        label: '1학년',
        steps: [
          RoadmapStep(
            title: '회로 기초 + 물리/수학 베이스',
            note: '기초가 전부를 결정함',
            icon: Icons.electrical_services_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: '아두이노/라즈베리파이 프로젝트 1개',
            note: '센서 + 간단 제어 + 로그 저장',
            icon: Icons.memory_rounded,
            priority: 4,
          ),
        ],
      ),
      SemesterRoadmap(
        label: '전과 루트(선택)',
        steps: [
          RoadmapStep(
            title: '임베디드 기반 포폴 1개로 전과 설득',
            note: '“하드웨어+앱 연동”이 설득력 최강',
            icon: Icons.link_rounded,
            priority: 5,
          ),
        ],
      ),
    ],
    tips: const [
      '전과용 포폴은 “회로/센서 데이터를 앱에서 보여주는 것”만 해도 충분히 강함.',
    ],
  ),

  // =========================
  // 간호학과
  // =========================
  'nursing': DeptRoadmap(
    deptId: 'nursing',
    title: '간호학과 로드맵',
    subtitle: '이론-실습-국시 준비 흐름',
    transferOpen: true,
    suggestedTransfers: const ['보건의료복지학과', '식품영양학과'],
    timeline: const [
      SemesterRoadmap(
        label: '1학년',
        steps: [
          RoadmapStep(
            title: '기본 과학/기초간호 개념 정리',
            note: '암기 + 이해 병행',
            icon: Icons.menu_book_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: '실습 루틴 만들기',
            note: '기록 습관이 실습을 살림',
            icon: Icons.edit_note_rounded,
            priority: 4,
          ),
        ],
      ),
    ],
    tips: const ['로드맵은 “학기마다 실습/평가 기준”이 핵심이야.'],
  ),

  // =========================
  // 관광경영
  // =========================
  'tourism_mgmt': DeptRoadmap(
    deptId: 'tourism_mgmt',
    title: '관광경영학과 로드맵',
    subtitle: '기획 → 운영 → 포트폴리오(콘텐츠/서비스)',
    transferOpen: true,
    suggestedTransfers: const ['호텔항공경영학과', '글로벌비즈니스학과'],
    timeline: const [
      SemesterRoadmap(
        label: '1학년',
        steps: [
          RoadmapStep(
            title: '관광 산업 구조/트렌드 요약 노트',
            note: '관광은 “트렌드 반응 속도”가 중요',
            icon: Icons.travel_explore_rounded,
            priority: 4,
          ),
          RoadmapStep(
            title: '기획 포폴 1개 제작',
            note: '여행/캠퍼스 투어 코스 기획서',
            icon: Icons.description_rounded,
            priority: 4,
          ),
        ],
      ),
    ],
    tips: const ['“운영 관점”을 잡으면 평가가 확 올라감.'],
  ),

  // =========================
  // IT경영정보
  // =========================
  'it_business_info': DeptRoadmap(
    deptId: 'it_business_info',
    title: 'IT경영정보학과 로드맵',
    subtitle: '데이터/기획/PM 중심 루트',
    transferOpen: true,
    suggestedTransfers: const ['경영학과', '소프트웨어공학부'],
    timeline: const [
      SemesterRoadmap(
        label: '1학년',
        steps: [
          RoadmapStep(
            title: '서비스 기획 문서 1개 완성',
            note: '문제정의 → 타겟 → 기능 → 지표',
            icon: Icons.fact_check_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: '데이터 기초(SQL) 시작',
            note: '분석은 SQL이 1순위',
            icon: Icons.storage_rounded,
            priority: 4,
          ),
        ],
      ),
    ],
    tips: const ['“지표로 말하는 기획”이 전과/취업 모두에 강해.'],
  ),

  // =========================
  // 자율전공
  // =========================
  'free_major': DeptRoadmap(
    deptId: 'free_major',
    title: '자율전공학부 로드맵',
    subtitle: '전과 100% 가능 컨셉의 핵심: “탐색-검증-결정”',
    transferOpen: true,
    suggestedTransfers: const [
      '소프트웨어공학부',
      '경영학과',
      '전기전자공학과',
      '심리상담학과',
    ],
    timeline: const [
      SemesterRoadmap(
        label: '1학년 1학기',
        steps: [
          RoadmapStep(
            title: '관심 전공 3개 선정',
            note: '전공별 “강점/약점/필수과목” 비교',
            icon: Icons.filter_alt_rounded,
            priority: 5,
          ),
          RoadmapStep(
            title: '각 전공 미니 프로젝트 1개씩',
            note: '작게라도 “내가 할 수 있는지” 검증',
            icon: Icons.science_rounded,
            priority: 5,
          ),
        ],
      ),
      SemesterRoadmap(
        label: '1학년 2학기',
        steps: [
          RoadmapStep(
            title: '전과 목표 1개로 좁히기',
            note: '증빙 자료: 계획서 + 결과물',
            icon: Icons.flag_rounded,
            priority: 5,
          ),
        ],
      ),
    ],
    tips: const [
      '전과를 “안전장치”로 두되, 1학년 안에 “결정”하는 게 가장 효율적이야.',
    ],
  ),
};

/// 없으면 기본 로드맵(전체 공용)으로 대체
DeptRoadmap defaultRoadmapFor(String deptId) {
  return DeptRoadmapsFallback.build(deptId);
}

class DeptRoadmapsFallback {
  static DeptRoadmap build(String deptId) {
    return const DeptRoadmap(
      deptId: '_default',
      title: '학과 로드맵',
      subtitle: '기본 템플릿(데이터 확장 예정)',
      transferOpen: true,
      suggestedTransfers: [],
      timeline: [
        SemesterRoadmap(
          label: '1학년',
          steps: [
            RoadmapStep(
              title: '전공 탐색 + 필수 과목 파악',
              note: '학과 홈페이지/커리큘럼 체크',
              icon: Icons.search_rounded,
              priority: 4,
            ),
            RoadmapStep(
              title: '포트폴리오/활동 1개 만들기',
              note: '작게라도 결과물 남기기',
              icon: Icons.rocket_launch_rounded,
              priority: 4,
            ),
          ],
        ),
      ],
      tips: [
        '이 로드맵은 기본 템플릿이야. 학과별 데이터 확장하면 훨씬 강해져.',
      ],
    );
  }
}
