
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/timetable/data/timetable_repo.dart';
import 'package:apptech_flutter/features/timetable/presentation/timetable_screen.dart';
import 'package:apptech_flutter/features/timetable/presentation/widgets/week_grid.dart';

class HomeTimetablePreview extends StatelessWidget {
  const HomeTimetablePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TimeTableRepo>();
    final rows = repo.cartRows;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('내 시간표', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, TimeTableScreen.routeName),
                child: const Text('전체보기', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ 홈에서도 절대 RenderBox/오버플로우 안 나게 "고정 높이"
          SizedBox(
            height: 360,
            child: WeekGrid(
              rows: rows,
              minMin: 9 * 60,
              maxMin: 21 * 60,
              emptyHint: rows.isEmpty,
              hourHeight: 64,
              dayWidth: 112,
            ),
          ),

          if (repo.lastWarn.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              repo.lastWarn,
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ],
      ),
    );
  }
}