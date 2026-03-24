import 'dart:convert';

class PointsEntry {
  final String id;
  final int delta;
  final String reason;
  final int createdAtMs;

  const PointsEntry({
    required this.id,
    required this.delta,
    required this.reason,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'delta': delta,
        'reason': reason,
        'createdAtMs': createdAtMs,
      };

  static PointsEntry fromJson(Map<String, dynamic> j) => PointsEntry(
        id: j['id'] as String,
        delta: (j['delta'] as num).toInt(),
        reason: j['reason'] as String,
        createdAtMs: (j['createdAtMs'] as num).toInt(),
      );
}

class PointsLedgerRepo {
  // ✅ 외부에서도 쓰게 public으로!
  static const String ledgerKey = 'nasom_points_ledger_v1';
  static const int maxKeep = 300;

  static List<PointsEntry> decode(String raw) {
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => PointsEntry.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static String encode(List<PointsEntry> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }
}
