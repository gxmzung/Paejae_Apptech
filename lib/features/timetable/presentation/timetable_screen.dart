// lib/features/timetable/presentation/timetable_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/timetable/data/timetable_repo.dart';
import 'package:apptech_flutter/features/timetable/presentation/widgets/week_grid.dart';

class TimeTableScreen extends StatelessWidget {
  static const routeName = '/timetable';
  const TimeTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TimeTableRepo>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('시간표', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        actions: [
          IconButton(
            tooltip: repo.editMode ? '편집 종료' : '편집',
            onPressed: repo.toggleEditMode,
            icon: Icon(repo.editMode ? Icons.done_rounded : Icons.edit_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          if (repo.lastWarn.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Text(repo.lastWarn, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
          ],

          // ✅ 그리드는 항상 “높이 확정”
          SizedBox(
            height: 640,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 52 + 5 * 120, // 52(time) + 5days*dayWidth
                child: WeekGrid(
                  rows: repo.cartRows,
                  minMin: 9 * 60,
                  maxMin: 21 * 60,
                  emptyHint: repo.cartRows.isEmpty,
                  hourHeight: 80,
                  dayWidth: 120,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          _SearchFilterBar(repo: repo),

          const SizedBox(height: 12),

          _LectureList(repo: repo),
        ],
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final TimeTableRepo repo;
  const _SearchFilterBar({required this.repo});

  @override
  Widget build(BuildContext context) {
    final options = repo.getDivisionOptions();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: repo.setQuery,
            decoration: InputDecoration(
              hintText: '과목명/코드/교수/강의실 검색',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: repo.divisionFilter,
                      items: options.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
                      onChanged: (v) {
                        if (v != null) repo.setDivisionFilter(v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // ✅ 전체담기 버튼 제거
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.06),
                  foregroundColor: AppColors.paejaeNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: repo.clearCart,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('비우기', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LectureList extends StatelessWidget {
  final TimeTableRepo repo;
  const _LectureList({required this.repo});

  @override
  Widget build(BuildContext context) {
    final list = repo.all;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.black.withOpacity(0.06)),
        itemBuilder: (_, i) {
          final r = list[i];
          final inCart = repo.isInCart(r);

          return ListTile(
            dense: true,
            title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(
              '${r.code}${r.section.isNotEmpty ? '(${r.section})' : ''} · ${r.professor} · ${r.room}'.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.6)),
            ),
            trailing: IconButton(
              tooltip: inCart ? '빼기' : '담기',
              onPressed: () => inCart ? repo.remove(r) : repo.add(r),
              icon: Icon(
                inCart ? Icons.remove_circle_rounded : Icons.add_circle_rounded,
                color: inCart ? Colors.red.shade600 : AppColors.paejaeBlue,
              ),
            ),
          );
        },
      ),
    );
  }
}