import 'package:shared_preferences/shared_preferences.dart';

enum WidgetMode { tiny, medium, full }

class WidgetSettings {
  final WidgetMode mode;
  final bool loveMode;
  final bool notifyNextClass1h;

  const WidgetSettings({
    required this.mode,
    required this.loveMode,
    required this.notifyNextClass1h,
  });

  WidgetSettings copyWith({
    WidgetMode? mode,
    bool? loveMode,
    bool? notifyNextClass1h,
  }) {
    return WidgetSettings(
      mode: mode ?? this.mode,
      loveMode: loveMode ?? this.loveMode,
      notifyNextClass1h: notifyNextClass1h ?? this.notifyNextClass1h,
    );
  }
}

class WidgetSettingsRepo {
  WidgetSettingsRepo._();
  static final WidgetSettingsRepo instance = WidgetSettingsRepo._();

  static const _kMode = 'widget_mode_v1'; // tiny|medium|full
  static const _kLove = 'widget_love_mode_v1';
  static const _kNotify1h = 'notify_nextclass_1h_v1';

  Future<SharedPreferences> get _sp async => SharedPreferences.getInstance();

  WidgetMode _parseMode(String? v) {
    switch ((v ?? '').trim()) {
      case 'medium':
        return WidgetMode.medium;
      case 'full':
        return WidgetMode.full;
      case 'tiny':
      default:
        return WidgetMode.tiny;
    }
  }

  String _modeToStr(WidgetMode m) {
    switch (m) {
      case WidgetMode.medium:
        return 'medium';
      case WidgetMode.full:
        return 'full';
      case WidgetMode.tiny:
      default:
        return 'tiny';
    }
  }

  Future<WidgetSettings> load() async {
    final sp = await _sp;
    return WidgetSettings(
      mode: _parseMode(sp.getString(_kMode)),
      loveMode: sp.getBool(_kLove) ?? true,
      notifyNextClass1h: sp.getBool(_kNotify1h) ?? false,
    );
  }

  Future<void> save(WidgetSettings s) async {
    final sp = await _sp;
    await sp.setString(_kMode, _modeToStr(s.mode));
    await sp.setBool(_kLove, s.loveMode);
    await sp.setBool(_kNotify1h, s.notifyNextClass1h);
  }
}