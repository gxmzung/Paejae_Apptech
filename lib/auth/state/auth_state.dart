import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/firebase_auth_service.dart';

class AuthState extends ChangeNotifier {
  AuthState({
    FirebaseAuthService? firebaseAuthService,
  }) : _firebase = firebaseAuthService ?? FirebaseAuthService();

  final FirebaseAuthService _firebase;

  bool _isBooted = false;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isProfileCompleted = false;
  String? _errorMessage;

  User? _user;

  bool get isBooted => _isBooted;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileCompleted => _isProfileCompleted;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _user;

  Future<void> boot() async {
    _setLoading(true);
    _clearError();

    try {
      _user = _firebase.currentUser;
      _isLoggedIn = _user != null;

      if (_user != null) {
        _isProfileCompleted =
        await _firebase.isProfileCompleted(_user!.uid);
      } else {
        _isProfileCompleted = false;
      }
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
    } finally {
      _isBooted = true;
      _setLoading(false, notify: false);
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cred = await _firebase.signUpWithEmail(
        email: email,
        password: password,
      );

      _user = cred.user;
      _isLoggedIn = _user != null;
      _isProfileCompleted = false;

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cred = await _firebase.signInWithEmail(
        email: email,
        password: password,
      );

      _user = cred.user;
      _isLoggedIn = _user != null;

      if (_user != null) {
        _isProfileCompleted =
        await _firebase.isProfileCompleted(_user!.uid);
      } else {
        _isProfileCompleted = false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfile({
    required String nickname,
    required String department,
    required int? entranceYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = _user;
      if (user == null) {
        throw Exception('로그인 정보가 없습니다.');
      }

      await _firebase.saveUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        nickname: nickname.trim(),
        department: department.trim(),
        entranceYear: entranceYear,
      );

      _isProfileCompleted = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _firebase.signOut();

      _user = null;
      _isLoggedIn = false;
      _isProfileCompleted = false;
    } catch (e) {
      _errorMessage = _friendlyMessage(e);
    } finally {
      _setLoading(false, notify: false);
      notifyListeners();
    }
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

  String _friendlyMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return '이메일 형식이 올바르지 않아요.';
        case 'user-disabled':
          return '비활성화된 계정이에요.';
        case 'user-not-found':
          return '가입되지 않은 계정이에요.';
        case 'wrong-password':
        case 'invalid-credential':
          return '이메일 또는 비밀번호가 올바르지 않아요.';
        case 'email-already-in-use':
          return '이미 가입된 이메일이에요.';
        case 'weak-password':
          return '비밀번호가 너무 약해요. 6자 이상 입력해 주세요.';
        case 'operation-not-allowed':
          return '현재 이 로그인 방식은 사용할 수 없어요.';
        case 'too-many-requests':
          return '요청이 너무 많아요. 잠시 후 다시 시도해 주세요.';
        case 'network-request-failed':
          return '네트워크 연결을 확인해 주세요.';
        default:
          return error.message?.trim().isNotEmpty == true
              ? error.message!.trim()
              : '인증 처리 중 오류가 발생했어요.';
      }
    }

    return error.toString();
  }
}