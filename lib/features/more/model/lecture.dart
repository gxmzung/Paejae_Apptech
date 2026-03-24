class Lecture {
  final String type;   // 전필/전선/교필/교선 등
  final String code;   // 과목코드
  final String name;   // 과목명
  final int credit;    // 학점

  const Lecture({
    required this.type,
    required this.code,
    required this.name,
    required this.credit,
  });
}