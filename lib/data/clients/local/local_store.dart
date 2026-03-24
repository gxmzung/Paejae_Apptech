import 'package:flutter/foundation.dart';

class LocalStore extends ChangeNotifier {
  static final LocalStore I = LocalStore._();
  LocalStore._();

  final Map<String, Object?> _data = {};

  T? get<T>(String key) => _data[key] as T?;
  void set<T>(String key, T value) {
    _data[key] = value;
    notifyListeners();
  }

  void remove(String key) {
    _data.remove(key);
    notifyListeners();
  }
}
