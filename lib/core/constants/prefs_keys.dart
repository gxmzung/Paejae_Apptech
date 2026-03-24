class PrefKeys {
  PrefKeys._();

  // ===== Auth =====
  static const String authLoggedIn = 'auth_logged_in_v1';
  static const String authEmail = 'auth_email_v1';
  static const String authUserId = 'auth_user_id_v1';

  // ===== Points (너가 이미 쓰는 키) =====
  static const String nasomPoints = 'nasom_points_v1';

  // ===== Activity settings =====
  static const String strideMeters = 'stride_meters_v1';
  static const String goalSteps = 'goal_steps_v1';
  static const String kcalPerStep = 'kcal_per_step_v1';
  static const String userWeightKg = 'user_weight_kg_v1';
  static const String useWeightKcalModel = 'use_weight_kcal_model_v1';

  // ===== Daily activity state (앱이 참조하는 값들) =====
  static const String todayYmd = 'activity_today_ymd_v1';
  static const String stepsToday = 'activity_steps_today_v1';
  static const String caloriesToday = 'activity_calories_today_v1';
  static const String dailyEarned = 'activity_daily_earned_v1';
  static const String dailyCap = 'activity_daily_cap_v1';
}