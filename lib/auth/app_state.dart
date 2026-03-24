import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  // ✅ 지금은 로컬 상태로만 흉내 (나중에 SharedPreferences/서버 붙이면 됨)
  bool _signedUp = false;
  bool get signedUp => _signedUp;

  // 프로필 간단 저장 (예시)
  String studentId = '';
  String nickname = '';
  String grade = '';
  String gender = '';
  String college = '';

  void completeSignup({
    required String studentId,
    required String nickname,
    required String grade,
    required String gender,
    required String college,
  }) {
    this.studentId = studentId;
    this.nickname = nickname;
    this.grade = grade;
    this.gender = gender;
    this.college = college;

    _signedUp = true;
    notifyListeners();
  }

  void logout() {
    _signedUp = false;
    notifyListeners();
  }
}
