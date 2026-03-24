import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepsService {
  StepsService._();
  static final StepsService instance = StepsService._();

  StreamSubscription<StepCount>? _sub;
  final ValueNotifier<int> todaySteps = ValueNotifier<int>(0);

  // 센서가 주는 "누적 걸음"에서 오늘 시작 기준점을 빼서 "오늘 걸음"으로 변환
  int? _base;
  int? _lastRaw;

  static const _kBaseKey = 'steps_base_raw';
  static const _kDayKey = 'steps_base_day'; // yyyy-mm-dd

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<bool> ensurePermission() async {
    // Android: ACTIVITY_RECOGNITION
    // iOS: Motion & Fitness
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) return true;

    final req = await Permission.activityRecognition.request();
    return req.isGranted;
  }

  Future<void> start() async {
    final ok = await ensurePermission();
    if (!ok) {
      todaySteps.value = 0;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = _dayKey(DateTime.now());
    final savedDay = prefs.getString(_kDayKey);
    final savedBase = prefs.getInt(_kBaseKey);

    if (savedDay == today && savedBase != null) {
      _base = savedBase;
    } else {
      _base = null; // 오늘 첫 데이터 들어올 때 기준 세팅
      await prefs.setString(_kDayKey, today);
      await prefs.remove(_kBaseKey);
    }

    _sub?.cancel();
    _sub = Pedometer.stepCountStream.listen(
          (event) async {
        final raw = event.steps;
        _lastRaw = raw;

        final prefs = await SharedPreferences.getInstance();
        final today = _dayKey(DateTime.now());
        final savedDay = prefs.getString(_kDayKey);

        // 날짜 바뀌면 기준 리셋
        if (savedDay != today) {
          _base = null;
          await prefs.setString(_kDayKey, today);
          await prefs.remove(_kBaseKey);
        }

        // 기준점 없으면 "현재 raw"를 오늘 시작점으로 잡음
        _base ??= raw;
        await prefs.setInt(_kBaseKey, _base!);

        final steps = (raw - (_base ?? raw));
        todaySteps.value = steps < 0 ? 0 : steps;
      },
      onError: (e) {
        // 센서 없는 기기/권한 거부/플러그인 에러 등
        todaySteps.value = 0;
      },
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// 디버깅용: 현재 raw 누적값 확인하고 싶으면
  int? get lastRawSteps => _lastRaw;
}