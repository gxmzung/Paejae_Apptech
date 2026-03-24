import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import 'points_ledger.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  List<PointsEntry> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(PointsLedgerRepo.ledgerKey);
    final items = raw == null ? <PointsEntry>[] : PointsLedgerRepo.decode(raw);

    // 최신순
    items.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));

    if (!mounted) return;
    setState(() => _items = items);
  }

  String _fmtTime(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final mm = d.minute.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    return '${d.month}/${d.day} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('나섬포인트 내역',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Text(
              '포인트는 “왜 늘었는지/줄었는지” 기록이 남아야 정식 앱이 돼요.',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.75),
                  height: 1.35),
            ),
          ),
          const SizedBox(height: 12),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      size: 42, color: AppColors.paejaeBlue),
                  const SizedBox(height: 8),
                  const Text('아직 내역이 없어요',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('오늘 보상이나 활동으로 포인트를 받아보세요.',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.paejaeNavy.withValues(alpha: 0.65))),
                ],
              ),
            ),
          ..._items.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border:
                      Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        e.delta >= 0 ? Icons.add_rounded : Icons.remove_rounded,
                        color: AppColors.paejaeBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.reason,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(_fmtTime(e.createdAtMs),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.paejaeNavy
                                      .withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    Text(
                      (e.delta >= 0 ? '+${e.delta}' : '${e.delta}') + ' P',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: e.delta >= 0
                            ? AppColors.paejaeBlue
                            : AppColors.paejaeNavy,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
