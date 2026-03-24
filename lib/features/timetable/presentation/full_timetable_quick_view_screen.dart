// lib/features/timetable/presentation/full_timetable_quick_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/features/timetable/data/timetable_repo.dart';
import 'package:apptech_flutter/features/timetable/presentation/widgets/week_grid.dart';

class FullTimetableQuickViewScreen extends StatelessWidget {
  static const routeName = '/timetable/fullQuick';
  const FullTimetableQuickViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TimeTableRepo>();
    final rows = repo.selectedRows;

    final h = MediaQuery.of(context).size.height;
    final boxH = (h * 0.72).clamp(520.0, 720.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.65),
      appBar: AppBar(
        title: const Text('전체 시간표', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: '닫기',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 18),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: SizedBox(
            height: boxH,
            child: WeekGrid(
              rows: rows,
              minMin: 9 * 60,
              maxMin: 21 * 60,
              emptyHint: rows.isEmpty,
              hourHeight: 86,
              dayWidth: 128,
            ),
          ),
        ),
      ),
    );
  }
}