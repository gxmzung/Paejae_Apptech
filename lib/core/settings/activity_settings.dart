// lib/core/settings/activity_settings.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptech_flutter/core/constants/prefs_keys.dart';

class ActivitySettings {
  final double strideMeters; // 보폭(m)
  final int goalSteps; // 목표 걸음수
  final double kcalPerStep; // 기본 kcal/step
  final double? weightKg; // 체중(선택)
  final bool useWeightKcalModel; // ✅ 체중 기반 kcal 모델 사용 여부

  const ActivitySettings({
    required this.strideMeters,
    required this.goalSteps,
    required this.kcalPerStep,
    required this.weightKg,
    required this.useWeightKcalModel,
  });

  static const ActivitySettings defaults = ActivitySettings(
    strideMeters: 0.75,
    goalSteps: 6400,
    kcalPerStep: 0.045,
    weightKg: null,
    useWeightKcalModel: true, // 기본은 ON 추천
  );

  ActivitySettings copyWith({
    double? strideMeters,
    int? goalSteps,
    double? kcalPerStep,
    double? weightKg,
    bool clearWeight = false,
    bool? useWeightKcalModel,
  }) {
    return ActivitySettings(
      strideMeters: strideMeters ?? this.strideMeters,
      goalSteps: goalSteps ?? this.goalSteps,
      kcalPerStep: kcalPerStep ?? this.kcalPerStep,
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      useWeightKcalModel: useWeightKcalModel ?? this.useWeightKcalModel,
    );
  }
}

class ActivitySettingsRepo {
  static const String updatedAtKey = 'activity_settings_updated_at_ms_v1';

  static Future<ActivitySettings> load() async {
    final sp = await SharedPreferences.getInstance();

    final stride = (sp.getDouble(PrefKeys.strideMeters) ??
        ActivitySettings.defaults.strideMeters)
        .clamp(0.3, 2.0)
        .toDouble();

    final goal = (sp.getInt(PrefKeys.goalSteps) ?? ActivitySettings.defaults.goalSteps)
        .clamp(1000, 50000)
        .toInt();

    final kcal = (sp.getDouble(PrefKeys.kcalPerStep) ??
        ActivitySettings.defaults.kcalPerStep)
        .clamp(0.01, 0.2)
        .toDouble();

    final w = sp.getDouble(PrefKeys.userWeightKg);
    final weight = (w == null) ? null : w.clamp(30.0, 200.0).toDouble();

    // ✅ 에러 났던 키: 이제 PrefKeys에 존재함
    final useWeightModel = sp.getBool(PrefKeys.useWeightKcalModel) ??
        ActivitySettings.defaults.useWeightKcalModel;

    return ActivitySettings(
      strideMeters: stride,
      goalSteps: goal,
      kcalPerStep: kcal,
      weightKg: weight,
      useWeightKcalModel: useWeightModel,
    );
  }

  static Future<void> save(ActivitySettings s) async {
    final sp = await SharedPreferences.getInstance();

    await sp.setDouble(PrefKeys.strideMeters, s.strideMeters);
    await sp.setInt(PrefKeys.goalSteps, s.goalSteps);
    await sp.setDouble(PrefKeys.kcalPerStep, s.kcalPerStep);

    if (s.weightKg == null) {
      await sp.remove(PrefKeys.userWeightKg);
    } else {
      await sp.setDouble(PrefKeys.userWeightKg, s.weightKg!);
    }

    // ✅ 에러 났던 키: 이제 저장 가능
    await sp.setBool(PrefKeys.useWeightKcalModel, s.useWeightKcalModel);

    await sp.setInt(updatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }
}
