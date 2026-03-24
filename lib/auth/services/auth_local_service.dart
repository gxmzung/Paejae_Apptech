import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';

class AuthLocalService {
  static const String _sessionKey = 'auth.session.v1';

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(session.toJson());
    final ok = await prefs.setString(_sessionKey, jsonString);

    if (!ok) {
      throw Exception('세션 저장에 실패했습니다.');
    }
  }

  Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);

    if (jsonString == null || jsonString.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        final mapped = Map<String, dynamic>.from(decoded as Map);
        return AuthSession.fromJson(mapped);
      }

      return AuthSession.fromJson(decoded);
    } catch (_) {
      // 손상된 데이터면 삭제하고 null 반환
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.remove(_sessionKey);

    if (!ok) {
      throw Exception('세션 삭제에 실패했습니다.');
    }
  }

  Future<bool> hasSession() async {
    final session = await readSession();
    return session != null && session.isLoggedIn;
  }
}