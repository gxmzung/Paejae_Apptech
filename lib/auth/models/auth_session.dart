import 'auth_user.dart';

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;
  final bool isLoggedIn;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isLoggedIn,
  });

  factory AuthSession.empty() {
    return AuthSession(
      accessToken: '',
      refreshToken: '',
      user: AuthUser.empty(),
      isLoggedIn: false,
    );
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    AuthUser? user,
    bool? isLoggedIn,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'isLoggedIn': isLoggedIn,
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: AuthUser.fromJson(
        Map<String, dynamic>.from(json['user'] ?? const {}),
      ),
      isLoggedIn: json['isLoggedIn'] == true,
    );
  }

  @override
  String toString() {
    return 'AuthSession(accessToken: $accessToken, refreshToken: $refreshToken, isLoggedIn: $isLoggedIn, user: $user)';
  }
}