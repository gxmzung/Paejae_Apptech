import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:apptech_flutter/core/api/api_config.dart';

import '../models/auth_session.dart';
import '../models/auth_user.dart';

class AuthApiService {
  AuthApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = ApiConfig.baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> requestOtp(String email) async {
    final uri = _uri('/auth/request-otp');

    final res = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
      }),
    );

    final body = _tryDecodeJson(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300 || body['ok'] == false) {
      throw Exception(
        _extractMessage(body, fallback: '인증번호 발송에 실패했습니다.'),
      );
    }
  }

  Future<AuthVerifyResult> verifyOtp({
    required String email,
    required String code,
    required bool isLogin,
  }) async {
    final uri = _uri('/auth/verify-otp');

    final res = await _client.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'mode': isLogin ? 'login' : 'signup',
      }),
    );

    final body = _tryDecodeJson(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300 || body['ok'] == false) {
      throw Exception(
        _extractMessage(body, fallback: '인증번호 확인에 실패했습니다.'),
      );
    }

    final bool isNewUser = !isLogin;

    final session = AuthSession(
      accessToken: '',
      refreshToken: '',
      user: AuthUser(
        id: email,
        email: email,
        nickname: '',
        department: '',
        entranceYear: null,
        profileCompleted: !isNewUser,
      ),
      isLoggedIn: true,
    );

    return AuthVerifyResult(
      success: true,
      isNewUser: isNewUser,
      session: session,
    );
  }

  Future<AuthUser> completeProfile({
    required String email,
    required String nickname,
    required String department,
    required int? entranceYear,
  }) async {
    return AuthUser(
      id: email,
      email: email,
      nickname: nickname,
      department: department,
      entranceYear: entranceYear,
      profileCompleted: true,
    );
  }

  Map<String, dynamic> _tryDecodeJson(String raw) {
    if (raw.trim().isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'raw': raw};
    }
  }

  String _extractMessage(
      Map<String, dynamic> json, {
        required String fallback,
      }) {
    final candidates = [
      json['message'],
      json['detail'],
      json['error'],
      json['msg'],
    ];

    for (final item in candidates) {
      final text = item?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return fallback;
  }
}

class AuthVerifyResult {
  final bool success;
  final bool isNewUser;
  final AuthSession? session;

  const AuthVerifyResult({
    required this.success,
    required this.isNewUser,
    required this.session,
  });
}