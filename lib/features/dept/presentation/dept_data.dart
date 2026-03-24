// lib/features/intro/data/dept_data.dart
import 'dept_model.dart';

/// ✅ 학과 사진: assets/intro/001.png ~ 040.png 사용
String _assetNum(int n) => 'assets/intro/${n.toString().padLeft(3, '0')}.png';

/// ✅ 폴백 로고
const String fallbackLogo = 'assets/brand/paejae_logo.png';

/// ✅ 001~040 범위 밖이면 로고로 폴백
String safeDeptPhotoAsset(String asset) {
  final m = RegExp(r'assets/intro/(\d{3})\.png').firstMatch(asset);
  if (m == null) return asset;
  final n = int.tryParse(m.group(1)!) ?? 999;
  if (n >= 1 && n <= 40) return asset;
  return fallbackLogo;
}

/// ✅ (DeptInfo.id -> intro 이미지 번호) 001~039 전체 매핑
final Map<String, int> _deptImageNoById = {
  // 001~004
  'police_law_division': 1, // 경찰법학부
  'nursing': 2, // 간호학과
  'public_admin': 3, // 행정학과
  'japan': 4, // 일본학과

  // 005~008
  'software_game': 5, // 게임공학전공(소프트웨어공학부)
  'business_admin': 6, // 경영학과
  'korean_koredu': 7, // 국어국문한국어교육학과
  'it_business_info': 8, // IT경영정보학과

  // 009~012
  'architecture': 9, // 건축학과
  'horti_forest': 10, // 원예산림학과
  'health_med_welfare': 11, // 보건의료복지학과
  'biotech': 12, // 생명공학과

  // 013~016
  'art_game_animation': 13, // 게임애니메이션전공(아트앤웹툰학부)
  'food_nutrition': 14, // 식품영양학과
  'performing_arts': 15, // 공연예술학과
  'rail_construction': 16, // 철도건설공학과

  // 017~020
  'air_service': 17, // 항공서비스학과
  'culinary': 18, // 외식조리학과
  'media_contents': 19, // 미디어콘텐츠학과
  'ad_photo_video': 20, // 광고사진영상학과

  // 021~024
  'sports_marketing': 21, // 스포츠마케팅전공(레저스포츠학부)
  'smart_battery': 22, // 스마트배터리학과
  'tourism_mgmt': 23, // 관광경영학과
  'global_business': 24, // 글로벌비지니스학과

  // 025~028
  'sports_health_rehab': 25, // 스포츠지도·건강재활전공(레저스포츠학부)
  'early_childhood': 26, // 유아교육과
  'software_cs': 27, // 컴퓨터공학전공(소프트웨어공학부)
  'hotel_air_mgmt': 28, // 호텔항공경영학과

  // 029~032
  'landscape': 29, // 조경학과
  'software_security': 30, // 정보보안학전공(소프트웨어공학부)
  'drone_robot': 31, // 드론로봇공학과
  'design_division': 32, // 디자인학부

  // 033~036
  'beauty_care': 33, // 뷰티케어학과
  'software_sw': 34, // 소프트웨어학전공(소프트웨어공학부)
  'interior_arch': 35, // 실내건축학과
  'psych_counsel': 36, // 심리상담학과

  // 037~039
  'art_webtoon': 37, // 아트앤웹툰전공(아트앤웹툰학부)
  'fashion': 38, // 의류패션학과
  'ee': 39, // 전기전자공학과
};

/// ✅ DeptInfo.id만 넣으면 해당 학과 사진 자동 세팅
String deptPhoto(String deptId) {
  final n = _deptImageNoById[deptId];
  if (n == null) return fallbackLogo;
  return safeDeptPhotoAsset(_assetNum(n));
}

/// ✅ 39개(001~039) 전체
final List<DeptInfo> deptAll = [
  // =============================
  // 인문사회 (001,003,004,007,036,026)
  // =============================
  DeptInfo(
    id: 'police_law_division',
    name: '경찰법학부',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('police_law_division'),
    tags: ['경찰학', '법학', '공직', '윤리'],
    intro5: const [
      '경찰·법의 기본을 함께 학습해요.',
      '사례 기반으로 판단/문제해결을 훈련해요.',
      '공직 대비 로드맵을 체계적으로 준비해요.',
      '현장 감각과 윤리 의식을 균형 있게 키워요.',
      '치안·법률·행정 진로로 확장해요.',
    ],
    careers: const ['경찰', '공공기관', '법률/행정', '보안/안전'],
  ),
  DeptInfo(
    id: 'public_admin',
    name: '행정학과',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('public_admin'),
    tags: ['정책', '행정', '공공', '소방행정'],
    intro5: const [
      '행정/정책의 기초 이론을 탄탄히 다져요.',
      '사례·데이터 기반으로 문제를 분석해요.',
      '공공서비스 설계 관점을 학습해요.',
      '트랙/진로를 실무와 연결해요.',
      '공공/안전 분야로 진출을 준비해요.',
    ],
    careers: const ['공무원', '공공기관', '정책/기획', '안전/소방행정'],
  ),
  DeptInfo(
    id: 'japan',
    name: '일본학과',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('japan'),
    tags: ['일본어', '문화', '글로벌', '지역이해'],
    intro5: const [
      '일본어 실력과 문화 이해를 함께 키워요.',
      '프로젝트형 과제로 소통 능력을 강화해요.',
      '비즈니스/관광 등 실무로 연결해요.',
      '해외 교류·취업 기반을 준비해요.',
      '언어를 넘어 산업/지역 이해로 확장해요.',
    ],
    careers: const ['통번역', '관광/서비스', '무역/비즈니스', '글로벌 커리어'],
  ),
  DeptInfo(
    id: 'korean_koredu',
    name: '국어국문한국어교육학과',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('korean_koredu'),
    tags: ['국어', '문학', '한국어교육', '글쓰기'],
    intro5: const [
      '국어·문학의 기초부터 심화까지 학습해요.',
      '비평·분석·표현 능력을 실전형으로 키워요.',
      '한국어교육 역량을 함께 확장해요.',
      '콘텐츠·출판·교육 분야로 진로를 넓혀요.',
      '언어 감각과 소통 역량을 탄탄히 다져요.',
    ],
    careers: const ['교육', '콘텐츠/출판', '한국어교육', '기획/편집'],
  ),
  DeptInfo(
    id: 'psych_counsel',
    name: '심리상담학과',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('psych_counsel'),
    tags: ['심리', '상담', '관계', '치유'],
    intro5: const [
      '마음과 행동을 과학적으로 이해해요.',
      '상담 기초부터 적용까지 단계적으로 배워요.',
      '의사소통·공감·관계 기술을 훈련해요.',
      '실습 중심으로 상담 역량을 다져요.',
      '교육·복지·조직 등 다양한 현장으로 연결해요.',
    ],
    careers: const ['상담', '교육', '복지', 'HR/조직'],
  ),
  DeptInfo(
    id: 'early_childhood',
    name: '유아교육과',
    category: DeptCategory.humanitiesSocial,
    mascotAsset: deptPhoto('early_childhood'),
    tags: ['유아', '교육', '놀이', '실습'],
    intro5: const [
      '유아 발달 이해를 바탕으로 교육 역량을 키워요.',
      '놀이·수업 설계 능력을 단계적으로 훈련해요.',
      '현장 실습으로 실무 감각을 강화해요.',
      '교직·자격 준비를 체계적으로 지원해요.',
      '아이와 함께 성장하는 교육 전문가를 길러요.',
    ],
    careers: const ['유치원/어린이집', '교육기관', '아동콘텐츠', '아동 관련 직무'],
  ),

  // =============================
  // 경영/관광 (006,008,023,024,028,017)
  // =============================
  DeptInfo(
    id: 'business_admin',
    name: '경영학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('business_admin'),
    tags: ['경영', '회계', '재무', '마케팅'],
    intro5: const [
      '기업 운영과 관리의 핵심을 학습해요.',
      '회계·재무·마케팅·조직을 균형 있게 다져요.',
      '실무형 과제로 문제 해결 능력을 키워요.',
      '데이터 기반 의사결정 역량을 강화해요.',
      '기업/공공/창업 등 다양한 진로로 연결해요.',
    ],
    careers: const ['경영지원', '마케팅', '재무/회계', '전략/기획'],
  ),
  DeptInfo(
    id: 'it_business_info',
    name: 'IT경영정보학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('it_business_info'),
    tags: ['IT기획', '빅데이터', 'e-비즈니스', '디지털전환'],
    intro5: const [
      'IT와 경영을 연결하는 역량을 키워요.',
      '데이터 분석·서비스 기획을 실전형으로 학습해요.',
      '프로젝트로 분석/기획 능력을 강화해요.',
      '현업 도구/사례를 기반으로 실무 감각을 키워요.',
      'PM/데이터/컨설팅 진로로 확장해요.',
    ],
    careers: const ['IT기획/PM', '데이터/분석', '서비스 기획', '운영/컨설팅'],
  ),
  DeptInfo(
    id: 'tourism_mgmt',
    name: '관광경영학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('tourism_mgmt'),
    tags: ['관광', '서비스', '기획', 'MICE'],
    intro5: const [
      '관광 산업 구조와 트렌드를 이해해요.',
      '서비스 운영·기획 역량을 함께 키워요.',
      '현장 중심 과제로 실무 감각을 강화해요.',
      '지역·문화 자원과 연결해 콘텐츠를 만들어요.',
      '관광/여행 분야 커리어를 준비해요.',
    ],
    careers: const ['여행/관광', '콘텐츠 기획', '서비스 운영', '마이스(MICE)'],
  ),
  DeptInfo(
    id: 'global_business',
    name: '글로벌비지니스학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('global_business'),
    tags: ['글로벌', '전략', '마케팅', '무역'],
    intro5: const [
      '경영 핵심을 기반으로 글로벌 실무를 배워요.',
      '시장/데이터 기반 기획 능력을 키워요.',
      '프로젝트로 문제 해결력을 강화해요.',
      '포트폴리오 중심으로 취업 역량을 준비해요.',
      '국내외 비즈니스 현장으로 연결해요.',
    ],
    careers: const ['무역', '마케팅', '전략/기획', '스타트업'],
  ),
  DeptInfo(
    id: 'hotel_air_mgmt',
    name: '호텔항공경영학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('hotel_air_mgmt'),
    tags: ['호텔', '항공', '경영', 'CX'],
    intro5: const [
      '호텔·항공 산업의 운영/경영을 배워요.',
      '고객 경험(CX) 설계 관점을 익혀요.',
      '현장형 실습으로 실무 역량을 키워요.',
      '전공 지식에 자격·어학을 연결해요.',
      '서비스 산업 전반으로 진로를 확장해요.',
    ],
    careers: const ['호텔', '항공/지상직', '리조트', '서비스 기획/운영'],
  ),
  DeptInfo(
    id: 'air_service',
    name: '항공서비스학과',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('air_service'),
    tags: ['항공', '서비스', '커뮤니케이션', '글로벌'],
    intro5: const [
      '항공 서비스의 기본기부터 실전까지 훈련해요.',
      '응대·커뮤니케이션·이미지 메이킹을 강화해요.',
      '현장 중심 수업으로 실무 적응력을 키워요.',
      '자격/어학 준비를 전공 안에서 연결해요.',
      '글로벌 서비스 커리어를 준비해요.',
    ],
    careers: const ['승무원', '지상직', '공항 서비스', '관광/서비스'],
  ),

  // =============================
  // 생명/보건 (002,010,11,12,14,18,22,33)
  // =============================
  DeptInfo(
    id: 'nursing',
    name: '간호학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('nursing'),
    tags: ['간호', '임상', '실습', '윤리'],
    intro5: const [
      '임상 중심으로 간호 핵심 역량을 키워요.',
      '이론-실습을 연결해 현장 적응력을 강화해요.',
      '환자 안전과 윤리 의식을 함께 다져요.',
      '팀 기반 협업 능력을 훈련해요.',
      '다양한 보건의료 분야로 진로를 확장해요.',
    ],
    careers: const ['병원 간호사', '보건의료기관', '공공보건', '연구/교육'],
  ),
  DeptInfo(
    id: 'horti_forest',
    name: '원예산림학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('horti_forest'),
    tags: ['원예', '산림', '환경', '스마트팜'],
    intro5: const [
      '자연·환경 기반 지식을 실전으로 배워요.',
      '원예·산림 관리의 기초를 탄탄히 다져요.',
      '현장 중심 실습으로 실무 감각을 키워요.',
      '도시·조경·환경 분야로 확장해요.',
      '지속가능한 미래 역량을 갖춰요.',
    ],
    careers: const ['산림/환경', '원예/스마트팜', '공공기관', '조경/환경 연계'],
  ),
  DeptInfo(
    id: 'health_med_welfare',
    name: '보건의료복지학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('health_med_welfare'),
    tags: ['보건', '의료', '복지', '정책'],
    intro5: const [
      '보건·의료·복지를 융합적으로 이해해요.',
      '현장 기반 과제로 실무 감각을 키워요.',
      '정책·서비스 운영 관점을 함께 배워요.',
      '데이터 기반 문제 해결을 강화해요.',
      '공공/민간 보건·복지 분야로 연결해요.',
    ],
    careers: const ['보건행정', '복지기관', '공공기관', '서비스 운영'],
  ),
  DeptInfo(
    id: 'biotech',
    name: '생명공학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('biotech'),
    tags: ['바이오', '실험', '연구', '분석'],
    intro5: const [
      '생명과학 기반 기술을 폭넓게 배워요.',
      '실험·분석 중심으로 연구 역량을 키워요.',
      '바이오 산업 트렌드를 전공에 연결해요.',
      '팀 프로젝트로 문제 해결을 훈련해요.',
      '연구·산업 현장으로 진로를 확장해요.',
    ],
    careers: const ['바이오 기업', '연구소', '품질/분석', '대학원'],
  ),
  DeptInfo(
    id: 'food_nutrition',
    name: '식품영양학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('food_nutrition'),
    tags: ['영양', '식품', '건강', '위생'],
    intro5: const [
      '영양과 건강을 과학적으로 이해해요.',
      '식품·위생·조리의 기본을 함께 배워요.',
      '상담·식단 설계 역량을 키워요.',
      '현장 중심 실습으로 실무를 강화해요.',
      '건강/식품 산업 커리어로 연결해요.',
    ],
    careers: const ['영양사', '식품기업', '급식/기관', '건강 컨설팅'],
  ),
  DeptInfo(
    id: 'culinary',
    name: '외식조리학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('culinary'),
    tags: ['조리', '외식', '창업', 'F&B'],
    intro5: const [
      '조리 기술과 외식 경영을 함께 배워요.',
      '실습 중심으로 현장 경쟁력을 키워요.',
      '메뉴 개발과 기획 능력을 강화해요.',
      '창업·브랜딩 감각을 전공에 연결해요.',
      '외식 산업으로 진로를 확장해요.',
    ],
    careers: const ['셰프', '외식기업', 'F&B 기획', '창업'],
  ),
  DeptInfo(
    id: 'smart_battery',
    name: '스마트배터리학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('smart_battery'),
    tags: ['배터리', '에너지', '소재', '산업'],
    intro5: const [
      '배터리/에너지 산업 이해를 바탕으로 역량을 키워요.',
      '기초 과학과 공정 관점을 함께 익혀요.',
      '현장 수요 중심의 기술 트렌드를 학습해요.',
      '프로젝트로 문제 해결력을 강화해요.',
      '차세대 에너지 분야 커리어로 연결해요.',
    ],
    careers: const ['배터리/에너지', '소재/공정', '품질/분석', 'R&D'],
  ),
  DeptInfo(
    id: 'beauty_care',
    name: '뷰티케어학과',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('beauty_care'),
    tags: ['뷰티', '피부', '케어', '서비스'],
    intro5: const [
      '뷰티 케어의 기초부터 실전까지 학습해요.',
      '현장형 실습으로 실무 감각을 키워요.',
      '고객 상담/서비스 역량을 강화해요.',
      '트렌드 기반 포트폴리오를 쌓아요.',
      '뷰티 산업 진로로 연결해요.',
    ],
    careers: const ['뷰티/에스테틱', '브랜드/유통', '교육/강사', '창업'],
  ),

  // =============================
  // 공학 (016,31,39,29 + 소프트웨어공학부 4전공)
  // =============================
  DeptInfo(
    id: 'rail_construction',
    name: '철도건설공학과',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('rail_construction'),
    tags: ['철도', '토목', '인프라', '시공'],
    intro5: const [
      '철도 인프라의 기초부터 응용까지 학습해요.',
      '현장·시공 관점의 문제 해결을 훈련해요.',
      '안전/품질 기준을 실무와 연결해요.',
      '프로젝트로 설계·관리 능력을 키워요.',
      '인프라 산업 진로로 확장해요.',
    ],
    careers: const ['철도/인프라', '건설/시공', '공공기관', '안전/품질'],
  ),
  DeptInfo(
    id: 'drone_robot',
    name: '드론로봇공학과',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('drone_robot'),
    tags: ['드론', '로봇', '제어', '센서'],
    intro5: const [
      '드론/로봇의 기초 구조와 제어를 배워요.',
      '센서·임베디드 관점의 실습을 강화해요.',
      '자율/제어 알고리즘의 기초를 익혀요.',
      '팀 프로젝트로 제작 경험을 쌓아요.',
      '스마트 제조/모빌리티로 확장해요.',
    ],
    careers: const ['로봇/드론', '임베디드', '제어', 'R&D'],
  ),
  DeptInfo(
    id: 'ee',
    name: '전기전자공학과',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('ee'),
    tags: ['회로', '전자', '임베디드', '설계'],
    intro5: const [
      '전기·전자 기초부터 응용까지 탄탄히 배워요.',
      '실습 중심으로 하드웨어 감각을 키워요.',
      '임베디드·IoT로 확장해요.',
      '프로젝트 기반 문제 해결을 훈련해요.',
      '전기·전자 산업 진로로 연결해요.',
    ],
    careers: const ['하드웨어', '임베디드', 'IoT', 'R&D'],
  ),
  DeptInfo(
    id: 'landscape',
    name: '조경학과',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('landscape'),
    tags: ['조경', '도시', '환경', '설계'],
    intro5: const [
      '공간·환경 관점에서 설계를 배워요.',
      '도시·공원·경관 설계 역량을 키워요.',
      '현장 기반 프로젝트로 실무를 강화해요.',
      '친환경/지속가능 관점을 익혀요.',
      '도시·환경 분야 진로로 확장해요.',
    ],
    careers: const ['조경설계', '도시/환경', '공공기관', '공간기획'],
  ),

  // 소프트웨어공학부 4전공(005,027,030,034)
  DeptInfo(
    id: 'software_game',
    name: '게임공학전공(소프트웨어공학부)',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('software_game'),
    tags: ['게임', '엔진', '그래픽', '클라이언트'],
    intro5: const [
      '게임 제작 파이프라인을 실전형으로 학습해요.',
      '엔진 기반 개발 감각을 키워요.',
      '그래픽/사운드/플레이 설계를 이해해요.',
      '팀 프로젝트로 협업 경험을 쌓아요.',
      '게임/콘텐츠 산업으로 연결해요.',
    ],
    careers: const ['게임개발', '클라이언트', '콘텐츠', '기획/테크'],
  ),
  DeptInfo(
    id: 'software_cs',
    name: '컴퓨터공학전공(소프트웨어공학부)',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('software_cs'),
    tags: ['CS', '앱/웹', '백엔드', '시스템'],
    intro5: const [
      '컴퓨터과학 핵심을 기반으로 개발 역량을 키워요.',
      '자료구조/알고리즘/네트워크를 탄탄히 다져요.',
      '앱·웹·백엔드로 실전 프로젝트를 해요.',
      '포트폴리오 중심으로 취업 역량을 강화해요.',
      '다양한 IT 직무로 확장해요.',
    ],
    careers: const ['앱/웹 개발', '백엔드', '플랫폼', '데이터/AI'],
  ),
  DeptInfo(
    id: 'software_security',
    name: '정보보안학전공(소프트웨어공학부)',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('software_security'),
    tags: ['보안', '네트워크', '침해대응', '포렌식'],
    intro5: const [
      '보안 기초부터 실무 관점까지 학습해요.',
      '네트워크/시스템 보안을 이해해요.',
      '취약점 분석과 대응 능력을 훈련해요.',
      '보안 실습/프로젝트로 경험을 쌓아요.',
      '보안 직무 로드맵으로 연결해요.',
    ],
    careers: const ['보안관제', '침해대응', '보안컨설팅', '개발보안'],
  ),
  DeptInfo(
    id: 'software_sw',
    name: '소프트웨어학전공(소프트웨어공학부)',
    category: DeptCategory.engineering,
    mascotAsset: deptPhoto('software_sw'),
    tags: ['소프트웨어', '아키텍처', '클라우드', '서비스'],
    intro5: const [
      '소프트웨어 설계/구현 역량을 체계적으로 키워요.',
      '클린코드·아키텍처 감각을 익혀요.',
      '서비스 개발과 배포 관점을 학습해요.',
      '팀 프로젝트로 실전 개발 경험을 쌓아요.',
      '실무형 포트폴리오로 연결해요.',
    ],
    careers: const ['백엔드', '프론트엔드', '클라우드', 'PM/개발'],
  ),

  // =============================
  // 건축(009,035)  ✅ 여기 “비어있던 이유” 해결: architecture 카테고리로 분리
  // =============================
  DeptInfo(
    id: 'architecture',
    name: '건축학과',
    category: DeptCategory.architecture,
    mascotAsset: deptPhoto('architecture'),
    tags: ['건축', '설계', '구조', '공간'],
    intro5: const [
      '건축 설계의 기초부터 심화까지 학습해요.',
      '공간/구조/재료 관점을 함께 익혀요.',
      '프로젝트로 설계 사고를 강화해요.',
      '현장 이해를 통해 실무 감각을 키워요.',
      '건축·도시 분야로 확장해요.',
    ],
    careers: const ['건축설계', '시공/감리', '공공/도시', '공간기획'],
  ),
  DeptInfo(
    id: 'interior_arch',
    name: '실내건축학과',
    category: DeptCategory.architecture,
    mascotAsset: deptPhoto('interior_arch'),
    tags: ['실내', '인테리어', '공간', '디자인'],
    intro5: const [
      '실내 공간의 설계 원리를 배워요.',
      '사용자 경험 중심의 공간을 기획해요.',
      '재료/조명/가구 등 요소를 통합해요.',
      '프로젝트 기반으로 포트폴리오를 쌓아요.',
      '공간 디자인 커리어로 연결해요.',
    ],
    careers: const ['인테리어', '공간디자인', '브랜딩 공간', '전시/무대'],
  ),

  // =============================
  // 예술/디자인/콘텐츠 (013,15,19,20,32,37,38)
  // =============================
  DeptInfo(
    id: 'art_game_animation',
    name: '게임애니메이션전공(아트앤웹툰학부)',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('art_game_animation'),
    tags: ['애니', '캐릭터', '콘텐츠', '제작'],
    intro5: const [
      '애니/캐릭터/콘텐츠 제작 기초를 배워요.',
      '실습 중심으로 표현 역량을 키워요.',
      '프로젝트로 결과물을 만들어 포트폴리오를 쌓아요.',
      '협업 제작 프로세스를 경험해요.',
      '콘텐츠 산업 진로로 연결해요.',
    ],
    careers: const ['애니메이션', '캐릭터/일러스트', '콘텐츠', '기획/제작'],
  ),
  DeptInfo(
    id: 'performing_arts',
    name: '공연예술학과',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('performing_arts'),
    tags: ['공연', '연기', '무대', '제작'],
    intro5: const [
      '공연예술의 기초부터 실전까지 학습해요.',
      '무대/연기/제작 과정을 경험해요.',
      '현장형 실습으로 역량을 키워요.',
      '팀워크 기반 작품 제작을 진행해요.',
      '공연·콘텐츠 산업으로 연결해요.',
    ],
    careers: const ['공연/연기', '무대/제작', '콘텐츠', '기획/매니지먼트'],
  ),
  DeptInfo(
    id: 'media_contents',
    name: '미디어콘텐츠학과',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('media_contents'),
    tags: ['미디어', '콘텐츠', '영상', '디지털'],
    intro5: const [
      '디지털 콘텐츠 기획·제작을 배워요.',
      '영상/미디어 표현 역량을 키워요.',
      '프로젝트로 결과물을 만드는 경험을 쌓아요.',
      '플랫폼 트렌드를 분석해 적용해요.',
      '콘텐츠 산업 커리어로 연결해요.',
    ],
    careers: const ['콘텐츠 제작', '영상/편집', '미디어 기획', '디지털 마케팅'],
  ),
  DeptInfo(
    id: 'ad_photo_video',
    name: '광고사진영상학과',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('ad_photo_video'),
    tags: ['광고', '사진', '영상', '브랜딩'],
    intro5: const [
      '광고/브랜딩 관점의 제작 역량을 키워요.',
      '사진·영상 촬영/편집을 실전형으로 익혀요.',
      '콘셉트 기획부터 결과물까지 완성해요.',
      '포트폴리오 중심으로 성장해요.',
      '콘텐츠/광고 산업 진로로 연결해요.',
    ],
    careers: const ['광고/브랜딩', '사진/영상', '콘텐츠 제작', '크리에이터'],
  ),
  DeptInfo(
    id: 'design_division',
    name: '디자인학부',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('design_division'),
    tags: ['디자인', '시각', 'UX', '브랜딩'],
    intro5: const [
      '디자인 기초부터 응용까지 학습해요.',
      '시각/브랜딩/UX 관점을 강화해요.',
      '프로젝트로 포트폴리오를 쌓아요.',
      '협업 제작 과정으로 실무 감각을 키워요.',
      '디자인 산업 진로로 확장해요.',
    ],
    careers: const ['시각디자인', 'UX/UI', '브랜딩', '콘텐츠 디자인'],
  ),
  DeptInfo(
    id: 'art_webtoon',
    name: '아트앤웹툰전공(아트앤웹툰학부)',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('art_webtoon'),
    tags: ['웹툰', '일러스트', '스토리', '캐릭터'],
    intro5: const [
      '웹툰/일러스트 제작의 기초를 배워요.',
      '스토리·연출·캐릭터 설계를 훈련해요.',
      '연재형 제작 습관을 기르고 결과물을 쌓아요.',
      '프로젝트 중심 포트폴리오를 강화해요.',
      '콘텐츠 산업으로 연결해요.',
    ],
    careers: const ['웹툰 작가', '일러스트레이터', '콘텐츠 제작', '스토리 기획'],
  ),
  DeptInfo(
    id: 'fashion',
    name: '의류패션학과',
    category: DeptCategory.artDesign,
    mascotAsset: deptPhoto('fashion'),
    tags: ['패션', '의류', '스타일', '브랜딩'],
    intro5: const [
      '패션/의류의 기초부터 실무까지 학습해요.',
      '소재·패턴·스타일링 감각을 키워요.',
      '작품 제작과 포트폴리오를 강화해요.',
      '트렌드 분석으로 시장 감각을 익혀요.',
      '패션 산업 진로로 연결해요.',
    ],
    careers: const ['패션/의류', '브랜드', '스타일링', 'MD/기획'],
  ),

  // =============================
  // 레저스포츠 (021,25)
  // =============================
  DeptInfo(
    id: 'sports_marketing',
    name: '스포츠마케팅전공(레저스포츠학부)',
    category: DeptCategory.businessTourism,
    mascotAsset: deptPhoto('sports_marketing'),
    tags: ['스포츠', '마케팅', '기획', '이벤트'],
    intro5: const [
      '스포츠 산업 구조와 마케팅을 이해해요.',
      '이벤트/스폰서십 기획 역량을 키워요.',
      '현장형 프로젝트로 실무 감각을 강화해요.',
      '데이터 기반 기획/홍보를 학습해요.',
      '스포츠 비즈니스로 연결해요.',
    ],
    careers: const ['스포츠마케팅', '이벤트/기획', '구단/협회', '콘텐츠/홍보'],
  ),
  DeptInfo(
    id: 'sports_health_rehab',
    name: '스포츠지도·건강재활전공(레저스포츠학부)',
    category: DeptCategory.bioHealth,
    mascotAsset: deptPhoto('sports_health_rehab'),
    tags: ['스포츠지도', '재활', '운동처방', '헬스케어'],
    intro5: const [
      '운동 지도와 건강 재활 관점을 함께 배워요.',
      '기초 해부/생리 기반의 실무를 익혀요.',
      '현장 실습으로 지도 역량을 강화해요.',
      '운동처방/재활 프로그램 설계를 경험해요.',
      '헬스케어 분야로 확장해요.',
    ],
    careers: const ['트레이너', '운동처방', '재활/헬스케어', '스포츠 지도'],
  ),
];
