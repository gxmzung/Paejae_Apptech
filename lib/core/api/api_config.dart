import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _lanBaseUrl = 'http://192.168.0.10:8080';

  static String get baseUrl {
    if (_envBaseUrl.trim().isNotEmpty) {
      return _normalize(_envBaseUrl);
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'http://localhost:8080';
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      default:
        return _lanBaseUrl;
    }
  }

  static String _normalize(String url) {
    final trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}