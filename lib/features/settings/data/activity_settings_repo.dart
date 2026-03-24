import 'package:shared_preferences/shared_preferences.dart';

class ActivitySettings {
  final double? weightKg; // null이면 평균(기본 계산)
  final double strideMeters; // 고급
  final int goalSteps; // 고급

  const ActivitySettings({
    required this.weightKg,
    required this.strideMeters,
    required this.goalSteps,
  });

  static const defaults = ActivitySettings(
    weightKg: null,
    strideMeters: 0.75,
    goalSteps: 6400,
  );
}

class ActivitySettingsRepo {
  static const _kWeight = 'activity_weight_kg_v1';
  static const _kStride = 'activity_stride_m_v1';
  static const _kGoal = 'activity_goal_steps_v1';

  static Future<ActivitySettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final w = sp.getDouble(_kWeight); // null 가능
    final stride = sp.getDouble(_kStride) ?? ActivitySettings.defaults.strideMeters;
    final goal = sp.getInt(_kGoal) ?? ActivitySettings.defaults.goalSteps;

    return ActivitySettings(weightKg: w, strideMeters: stride, goalSteps: goal);
  }

  static Future<void> setWeight(double? kg) async {
    final sp = await SharedPreferences.getInstance();
    if (kg == null) {
      await sp.remove(_kWeight);
    } else {
      await sp.setDouble(_kWeight, kg);
    }
  }

  static Future<void> setStride(double meters) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(_kStride, meters);
  }

  static Future<void> setGoalSteps(int steps) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kGoal, steps);
  }
}
