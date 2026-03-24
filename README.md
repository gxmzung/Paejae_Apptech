📒 Developer Notes — v0.4 (오늘 기준)
0) 빌드/배포 메모

Android APK: build/app/outputs/flutter-apk/app-debug.apk

공유 시: app-debug.apk만 전달하면 설치 가능
(.sha1 파일은 무결성 체크용이라 보통 배포에 불필요)

1) 현재 구현된 기능(앱 전체 기능 목록)
   A. 홈(Home)

1) 걸음수 측정 (pedometer 기반)

기기 누적 걸음값을 기반으로 “오늘 걸음(자정 기준)” 계산

앱 실행 중 자정 넘어가면 자동 리셋 처리

Android 권한: activityRecognition 요청

2) 활동 지표 계산

오늘 걸음수(steps)

거리(km) 추정: stride 기반

칼로리(kcal) 추정: km 기반

3) 포인트 시스템(나섬포인트)

보유 포인트 표시

포인트 변경사항 저장(SharedPreferences)

4) 포인트 내역(Points Ledger)

포인트 증감 기록 저장

“내역 화면”으로 이동 가능

5) 1일 1회 데일리 보상 + 스트릭

하루 1회 포인트 지급

스트릭 연속 일수 저장

7/14/30일 보너스 지급 구조 포함

6) 걸음 보상 자동 지급

1000걸음 단위마다 +10P 자동 지급

중복 지급 방지(버킷 방식)

지급 시 토스트(SnackBar) 안내

내역(ledger) 기록 포함

7) 센서 상태 디버그 표시(iOS/공통)

센서 스트림 정상/비정상 표시

마지막 이벤트 시각 표시

에러 메시지 표시

설정 열기 / 재시도 버튼 제공

8) 캠퍼스 바로가기(4x4 Grid)

빈 강의실

흡연구역

안전제보

냉장고 레시피

교내 지도

챌린지

랭킹

포인트 내역

체감지수

번역기(학교–학생)

학기 타임라인

학점 계산기

학식 혼잡도

근처 맛집

푸드트럭 일정

기숙사 벌점 계산기

9) 홈 내 도구 화면(데모)

런닝/산책 타이머: 시작/일시정지/리셋

스터디 알람(데모): 시간 슬라이더 + 진동 토글 + 시작

B. 랭킹(Ranking) v2

1) 랭킹 점수 = 지갑 포인트와 분리

지갑 포인트: 나섬포인트(교환용)

랭킹 점수: 걷기/출석/퀘스트/챌린지 합산 점수

2) 랭킹 점수 계산 규칙(v2)

걷기 점수: 오늘걸음/20 (20보 = 1점), 최대 600점(=12,000보)

출석: 1회 25점 (현재는 키만 존재, 실제 기능은 추후)

퀘스트: 1개 40점 (추후)

챌린지 완료: 1개 120점 (추후)

3) 탭 3종

전체 / 학과 / 친구

4) 필터

학과 / 학번 / 학년 필터

적용 버튼

5) 친구 탭(실데이터 기반)

FriendsScreen에 저장된 친구 목록(SharedPreferences)을 읽어 표시

6) TOP 보너스 자동 지급(하루 1회)

전체 TOP10: +20P 자동 지급(지갑 포인트)

학과 TOP10: +10P 자동 지급(지갑 포인트)

지급 내역 ledger 기록

7) UX

뒤로가기 버튼 제공

새로고침 버튼 제공

“나” 강조 표시

C. 포인트(Points)

포인트 내역 화면(PointsHistoryScreen)

ledger 저장/조회 구조(PointsLedgerRepo)

D. 기타 연결된 화면(바로가기/더보기 기반)

이 항목은 “현재 코드에서 화면 이동 링크가 존재하는 기능” 기준이야.

교내 지도(CampusMapScreen)

챌린지(ChallengeScreen)

랭킹(RankingScreen)

학점 계산기(GpaCalculatorScreen)

학식 혼잡(FoodFlowScreen)

기숙사 벌점(DormDemeritScreen)

체감지수(FacilityIndexScreen)

번역기(SchoolStudentTranslatorScreen)

학기 타임라인(SemesterTimelineScreen)

근처 맛집(NearbyEatsScreen)

푸드트럭 일정(FoodTruckScheduleScreen)

빈 강의실(EmptyRoomScreen)

흡연구역(SmokingZoneScreen)

안전제보(SafetyAlertScreen)

냉장고 레시피(FridgeRecipeScreen)

친구(FriendsScreen)

(추가로 import 돼있지만 실제 구현 여부에 따라 컴파일 주의)

DeptWiki / Credits / MyScreen / AcademicCalendar / SeniorTip / ClubReview 등

2) 데이터 저장 구조(SharedPreferences 키 정리)

nasom_points_v1: 지갑 포인트(나섬포인트)

steps_day_yyyymmdd_v1: 오늘 날짜키

steps_baseline_total_v1: 오늘 baseline(기기누적-오늘걸음 계산용)

steps_today_cache_v1: 오늘 걸음 캐시(랭킹에서 사용)

reward_day_yyyymmdd_v1: 오늘 보상 받았는지

reward_last_day_yyyymmdd_v1: 마지막 보상 날짜

reward_streak_v1: 스트릭

step_reward_day_yyyymmdd_v1: 걸음 보상 기준 날짜

step_reward_bucket_v1: 오늘 몇 번째 1000걸음 구간까지 지급했는지

rank_score_v2: 랭킹 점수

rank_breakdown_v2_json: 점수 breakdown 문자열

friends_list_v1: 친구 리스트 (CSV “name|dept|year|grade”)

3) 알려진 이슈 / 주의사항 (v0.4)

걸음수 정확도는 OS/센서 권한에 강하게 의존

Android: 활동 권한 필요

iOS: Motion/Fitness/Health 설정에 따라 스트림이 안 뜰 수 있음(홈 디버그 패널로 추적)

랭킹은 현재 “데모 유저 랜덤 생성”

내 점수/친구는 실데이터 기반

전체 유저는 서버 연동 전까지 데모

출석/퀘스트/챌린지 점수는 키만 존재

실제 기능 UI/로직 추가 전에는 0점

화면 import는 있으나 파일이 없으면 컴파일 에러

“없을 수 있는 화면”은 연결 전 주석처리 필요

🚀 향후 추가/개선 계획 (Roadmap)
v0.5 목표 (안정화 + 핵심 UX 완성)

홈 화면 정리

TodayActivityCard vs ActivityHero 중복 요소 통합(정보 밀도 조절)

카드 높이/여백 통일(디자인 시스템화)

걸음 캐시 저장 표준화

steps_today_cache_v1을 HomeScreen에서 항상 갱신

앱 재시작/백그라운드 복귀 시 값 안정화

포인트 내역 UI 강화

필터(획득/사용/보너스)

기간별 합계(오늘/주간/월간)

뒤로가기 UX 일관화

모든 주요 화면 AppBar leading 표준 적용

v0.6 목표 (정식앱 느낌 + 캠퍼스 실사용 기능 강화)

푸시/알림 구조

안전제보 알림, 챌린지 알림, 학사 일정 알림

출석 기능 구현

QR / 위치 기반 / 시간 기반 중 1개 선택하여 MVP 구축

출석 포인트 + 랭킹 점수 연동

친구 초대/코드 공유

추천 코드 시스템 + 초대 보상

친구끼리 일일 경쟁/주간 경쟁

v0.7 목표 (데이터 기반 + 운영 가능한 구조)

랭킹 서버화(파이어베이스 or FastAPI)

유저 프로필/점수/친구/학과 랭킹 실데이터

부정행위 탐지

비정상 걸음 패턴(짧은 시간 폭증) 감지

포인트 상점/교환 기능

기프티콘/학교 제휴 쿠폰/학생회 연동 가능 구조

v1.0 목표 (배재대 “정식앱급”)

캠퍼스맵 고도화

건물 내부 길찾기(가능하면)

흡연구역 표시(사용자 요청 반영)

기숙사 벌점 계산기 고도화

벌점 규정 DB화 + 누적/예상 벌점

캠퍼스 미세 스트레스 지도(아이디어 9) 통합

교수님 스타일 번역기(아이디어 6) 통합

루머 차단기(아이디어 12) 통합

암묵지 위키/선배 조언/학기 생존 타임라인(아이디어 1~8) 통합