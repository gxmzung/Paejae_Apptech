import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:apptech_flutter/core/api/api_config.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

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
    final res = await _client.post(
      _uri('/auth/request-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );

    final body = _tryDecodeJson(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300 || body['ok'] == false) {
      throw Exception(
        _extractMessage(body, fallback: '인증번호 발송에 실패했어요.'),
      );
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    final res = await _client.post(
      _uri('/auth/verify-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      }),
    );

    final body = _tryDecodeJson(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300 || body['ok'] == false) {
      throw Exception(
        _extractMessage(body, fallback: '인증번호 확인에 실패했어요.'),
      );
    }
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