import 'package:shared_preferences/shared_preferences.dart';

class TimetableWidgetBridge {
  static const _kWidgetKey = 'widget_today_classes';

  /// 오늘 수업 문자열 저장
  /// 예: "09:00 컴퓨터구조\n11:00 운영체제"
  static Future<void> updateTodayClasses(List<String> classes) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kWidgetKey, classes.join('\n'));
  }

  static Future<String> loadForWidget() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kWidgetKey) ?? '오늘 수업 없음';
  }
}