import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../services/auth_api_service.dart';
import '../services/profile_store_service.dart';

class AuthState extends ChangeNotifier {
  AuthState({
    AuthApiService? api,
    ProfileStoreService? profileStore,
  })  : _api = api ?? AuthApiService(),
        _profileStore = profileStore ?? ProfileStoreService();

  final AuthApiService _api;
  final ProfileStoreService _profileStore;

  static const _kEmailKey = 'auth_email_v1';
  static const _kVerifiedKey = 'auth_verified_v1';

  bool _isBooted = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isProfileCompleted = false;

  String? _email;
  String? _errorMessage;
  AuthUser? _user;

  bool get isBooted => _isBooted;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileCompleted => _isProfileCompleted;
  String? get email => _email;
  String? get errorMessage => _errorMessage;
  AuthUser? get currentUser => _user;

  Future<void> boot() async {
    _setLoading(true);
    _clearError();

    try {
      final sp = await SharedPreferences.getInstance();
      final savedEmail = sp.getString(_kEmailKey);
      final verified = sp.getBool(_kVerifiedKey) ?? false;

      if (savedEmail != null && verified) {
        _email = savedEmail;
        _isLoggedIn = true;

        final profile = await _profileStore.fetchProfile(savedEmail);
        _user = profile;
        _isProfileCompleted = profile?.profileCompleted == true;
      } else {
        _isLoggedIn = false;
        _isProfileCompleted = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isBooted = true;
      _setLoading(false, notify: false);
      notifyListeners();
    }
  }

  Future<void> requestOtp(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final normalized = email.trim().toLowerCase();

      if (!normalized.endsWith('@pcu.ac.kr')) {
        throw Exception('학교 이메일(@pcu.ac.kr)만 사용할 수 있어요.');
      }

      await _api.requestOtp(normalized);
    } catch (e) {
      _errorMessage = _prettyError(e);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final normalized = email.trim().toLowerCase();

      await _api.verifyOtp(
        email: normalized,
        code: code,
      );

      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kEmailKey, normalized);
      await sp.setBool(_kVerifiedKey, true);

      _email = normalized;
      _isLoggedIn = true;

      final profile = await _profileStore.fetchProfile(normalized);
      _user = profile;
      _isProfileCompleted = profile?.profileCompleted == true;
    } catch (e) {
      _errorMessage = _prettyError(e);
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> completeProfile({
    required String nickname,
    required String department,
    required int? entranceYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final email = _email;
      if (email == null || email.isEmpty) {
        throw Exception('인증된 사용자 정보가 없어요.');
      }

      await _profileStore.saveProfile(
        email: email,
        nickname: nickname,
        department: department,
        entranceYear: entranceYear,
      );

      final profile = await _profileStore.fetchProfile(email);
      _user = profile;
      _isProfileCompleted = profile?.profileCompleted == true;
    } catch (e) {
      _errorMessage = _prettyError(e);
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kEmailKey);
    await sp.remove(_kVerifiedKey);

    _email = null;
    _user = null;
    _isLoggedIn = false;
    _isProfileCompleted = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value, {bool notify = true}) {
    _isLoading = value;
    if (notify) notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _prettyError(Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isEmpty) return '알 수 없는 오류가 발생했어요.';
    return raw;
  }
}