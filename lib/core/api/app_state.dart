import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _booted = false;

  int _steps = 0;
  int _todayPointBySteps = 0;
  int _todayCalories = 0;

  static const int _dailyGoalSteps = 3000;
  static const int _dailyPointMax = 30;

  bool get booted => _booted;

  int get steps => _steps;
  int get todayPointBySteps => _todayPointBySteps;
  int get todayCalories => _todayCalories;

  bool get isDailyPointMaxed => _todayPointBySteps >= _dailyPointMax;

  double get todayProgress {
    if (_dailyGoalSteps <= 0) return 0.0;
    return (_steps / _dailyGoalSteps).clamp(0.0, 1.0);
  }

  Future<void> boot() async {
    _booted = true;
    notifyListeners();
  }

  Future<void> logout() async {
    notifyListeners();
  }

  void updateDailyActivity({
    required int steps,
    required int todayPointBySteps,
    required int todayCalories,
  }) {
    _steps = steps;
    _todayPointBySteps = todayPointBySteps;
    _todayCalories = todayCalories;
    notifyListeners();
  }

  void resetDailyActivity() {
    _steps = 0;
    _todayPointBySteps = 0;
    _todayCalories = 0;
    notifyListeners();
  }
}