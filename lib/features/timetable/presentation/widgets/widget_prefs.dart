import 'package:shared_preferences/shared_preferences.dart';

enum WidgetMode { romance, small, medium, full }

extension WidgetModeX on WidgetMode {
  String get label {
    switch (this) {
      case WidgetMode.romance:
        return '연애모드';
      case WidgetMode.small:
        return '초소형';
      case WidgetMode.medium:
        return '중형(3줄)';
      case WidgetMode.full:
        return '전체';
    }
  }
}

class WidgetPrefs {
  WidgetPrefs._();

  static const _kMode = 'tt_widget_mode';
  static const _kMask = 'tt_widget_privacy_mask';
  static const _kBefore = 'tt_widget_notify_before_min';

  static Future<void> saveMode(WidgetMode v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kMode, v.index);
  }

  static Future<WidgetMode> loadMode() async {
    final sp = await SharedPreferences.getInstance();
    final i = sp.getInt(_kMode);
    if (i == null || i < 0 || i >= WidgetMode.values.length) return WidgetMode.romance;
    return WidgetMode.values[i];
  }

  static Future<void> savePrivacyMask(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMask, v);
  }

  static Future<bool> loadPrivacyMask() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kMask) ?? true;
  }

  static Future<void> saveNotifyBeforeMin(int v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kBefore, v);
  }

  static Future<int> loadNotifyBeforeMin() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kBefore) ?? 60;
  }
}