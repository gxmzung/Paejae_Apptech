import 'package:shared_preferences/shared_preferences.dart';

class PointsRepo {
  static const _kPoints = 'walk_points_v1';

  Future<int> loadPoints() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kPoints) ?? 0;
  }

  Future<void> savePoints(int v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kPoints, v);
  }

  Future<bool> spend(int cost) async {
    final p = await loadPoints();
    if (p < cost) return false;
    await savePoints(p - cost);
    return true;
  }
}