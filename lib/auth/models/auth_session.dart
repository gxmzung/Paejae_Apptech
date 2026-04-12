class AuthUser {
  final String email;
  final String nickname;
  final String department;
  final int? entranceYear;
  final bool isVerifiedStudent;
  final bool profileCompleted;

  const AuthUser({
    required this.email,
    required this.nickname,
    required this.department,
    required this.entranceYear,
    required this.isVerifiedStudent,
    required this.profileCompleted,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      email: (map['email'] ?? '').toString(),
      nickname: (map['nickname'] ?? '').toString(),
      department: (map['department'] ?? '').toString(),
      entranceYear: (map['entranceYear'] as num?)?.toInt(),
      isVerifiedStudent: map['isVerifiedStudent'] == true,
      profileCompleted: map['profileCompleted'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'department': department,
      'entranceYear': entranceYear,
      'isVerifiedStudent': isVerifiedStudent,
      'profileCompleted': profileCompleted,
    };
  }
}