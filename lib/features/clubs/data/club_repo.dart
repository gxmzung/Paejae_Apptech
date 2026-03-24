import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'club_model.dart';

class ClubRepo {
  static const String _assetPath = 'assets/data/clubs.json';

  Future<List<ClubModel>> loadClubs() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;

    return decoded
        .map((e) => ClubModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}