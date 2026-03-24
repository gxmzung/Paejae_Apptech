class TTSlot {
  final int day;      // 1=월,2=화,3=수,4=목,5=금
  final int start;    // 교시 시작 (예: 3교시)
  final int end;      // 교시 끝 (포함, 예: 4교시)
  final String name;  // 과목명
  final String room;  // 강의실(옵션)
  final String prof;  // 교수(옵션)

  const TTSlot({
    required this.day,
    required this.start,
    required this.end,
    required this.name,
    this.room = '',
    this.prof = '',
  });
}

class TTTemplateKey {
  final String dept;     // ex) 컴퓨터공학전공(소프트웨어공학부)
  final String grade;    // ex) 1학년
  final int semester;    // 1 or 2
  const TTTemplateKey({required this.dept, required this.grade, required this.semester});

  @override
  bool operator ==(Object other) =>
      other is TTTemplateKey &&
          other.dept == dept &&
          other.grade == grade &&
          other.semester == semester;

  @override
  int get hashCode => Object.hash(dept, grade, semester);
}

/// ✅ 추천 시간표 템플릿 모음
/// - 여기만 늘려가면 타 학과/타 학년/2학기 확장 끝
final Map<TTTemplateKey, List<TTSlot>> kRecommendTemplates = {
  // 예시) 컴공 1학년 1학기 (네가 올린 학교 배정표 기반 “형식”)
  TTTemplateKey(dept: '컴퓨터공학전공(소프트웨어공학부)', grade: '1학년', semester: 1): const [
    // 화: 3~4 컴퓨팅사고
    TTSlot(day: 2, start: 3, end: 4, name: '컴퓨팅사고', room: 'J116-1', prof: '고경민'),
    // 화: 5~8 기초C프로그래밍
    TTSlot(day: 2, start: 5, end: 8, name: '기초C프로그래밍', room: 'C401', prof: '김창수'),

    // 수: 5~6 컴퓨팅사고
    TTSlot(day: 3, start: 5, end: 6, name: '컴퓨팅사고', room: 'J116-1', prof: '고경민'),
    // 수: 7 전공의이해
    TTSlot(day: 3, start: 7, end: 7, name: '전공의이해', room: 'C105', prof: '이창훈'),

    // 목: 5~8 기초웹프로그래밍
    TTSlot(day: 4, start: 5, end: 8, name: '기초웹프로그래밍', room: 'MC408', prof: '김병용'),

    // 금: 6 채플
    TTSlot(day: 5, start: 6, end: 6, name: '채플1', room: 'AM108', prof: '이성덕'),

    // 온라인 교과(시간고정 없으면 day/start/end 넣지 말고 별도 리스트로 관리 추천)
  ],
};