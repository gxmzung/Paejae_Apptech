class AuthUser {
  final String id;
  final String email;
  final String nickname;
  final String department;
  final int? entranceYear;
  final bool profileCompleted;

  const AuthUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.department,
    required this.entranceYear,
    required this.profileCompleted,
  });

  factory AuthUser.empty() {
    return const AuthUser(
      id: '',
      email: '',
      nickname: '',
      department: '',
      entranceYear: null,
      profileCompleted: false,
    );
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? nickname,
    String? department,
    int? entranceYear,
    bool? profileCompleted,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      department: department ?? this.department,
      entranceYear: entranceYear ?? this.entranceYear,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'department': department,
      'entranceYear': entranceYear,
      'profileCompleted': profileCompleted,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      entranceYear: _parseNullableInt(json['entranceYear']),
      profileCompleted: json['profileCompleted'] == true,
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, nickname: $nickname, department: $department, entranceYear: $entranceYear, profileCompleted: $profileCompleted)';
  }
}