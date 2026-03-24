import 'package:flutter/material.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/timetable/data/lecture_xlsx_loader.dart';
import 'package:apptech_flutter/features/timetable/presentation/widgets/widget_prefs.dart';
import 'package:apptech_flutter/features/timetable/domain/lecture_row.dart';


class TimetableWidgetPreviewCard extends StatelessWidget {
  final WidgetMode mode;
  final bool privacyMask;
  final int notifyBeforeMin;
  final List<LectureRow> selectedRows;

  const TimetableWidgetPreviewCard({
    super.key,
    required this.mode,
    required this.privacyMask,
    required this.notifyBeforeMin,
    required this.selectedRows,
  });

  @override
  Widget build(BuildContext context) {
    final today = _todayRows(selectedRows);
    final next = _nextRow(selectedRows);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: privacyMask ? Colors.white.withValues(alpha: 0.68) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_clock_rounded, size: 18, color: AppColors.paejaeNavy),
              const SizedBox(width: 6),
              Text(
                '미리보기',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  mode.label,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeNavy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildByMode(today: today, next: next),
        ],
      ),
    );
  }

  Widget _buildByMode({required List<LectureRow> today, required LectureRow? next}) {
    switch (mode) {
      case WidgetMode.romance:
        return _RomanceView(next: next, notifyBeforeMin: notifyBeforeMin);
      case WidgetMode.small:
        return _SmallView(today: today);
      case WidgetMode.medium:
        return _MediumView(today: today);
      case WidgetMode.full:
        return _FullView(rows: selectedRows);
    }
  }

  // ===== very simple helper (시간표 파싱 정교화 전까지는 보수적으로) =====

  List<LectureRow> _todayRows(List<LectureRow> rows) {
    final d = DateTime.now().weekday; // 1=Mon ... 7=Sun
    const map = {1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'};
    final key = map[d] ?? '월';
    return rows.where((r) => r.timeRaw.contains(key)).toList();
  }

  LectureRow? _nextRow(List<LectureRow> rows) {
    // 1단계: “오늘 수업 중 첫 번째”를 next로 간주 (정교 파싱은 2단계에서)
    final today = _todayRows(rows);
    if (today.isEmpty) return null;
    return today.first;
  }
}

// ================= UI blocks =================

class _RomanceView extends StatelessWidget {
  final LectureRow? next;
  final int notifyBeforeMin;

  const _RomanceView({required this.next, required this.notifyBeforeMin});

  @override
  Widget build(BuildContext context) {
    if (next == null) {
      return const Text(
        '다음 수업 없음 ✨',
        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeNavy),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('다음 수업', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(
          next!.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          '${next!.timeRaw} · ${next!.professor}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 10),
        Text(
          '알림: ${notifyBeforeMin}분 전',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black.withValues(alpha: 0.55)),
        ),
      ],
    );
  }
}

class _SmallView extends StatelessWidget {
  final List<LectureRow> today;
  const _SmallView({required this.today});

  @override
  Widget build(BuildContext context) {
    final show = today.take(1).toList();
    if (show.isEmpty) {
      return const Text('오늘 수업 없음', style: TextStyle(fontWeight: FontWeight.w900));
    }
    final x = show.first;
    return Text(
      '${x.name}\n${x.timeRaw}',
      style: const TextStyle(fontWeight: FontWeight.w900),
    );
  }
}

class _MediumView extends StatelessWidget {
  final List<LectureRow> today;
  const _MediumView({required this.today});

  @override
  Widget build(BuildContext context) {
    final show = today.take(3).toList();
    if (show.isEmpty) {
      return const Text('오늘 수업 없음', style: TextStyle(fontWeight: FontWeight.w900));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: show.map((x) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '• ${x.name} (${x.timeRaw})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }).toList(),
    );
  }
}

class _FullView extends StatelessWidget {
  final List<LectureRow> rows;
  const _FullView({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Text('시간표가 비어있음', style: TextStyle(fontWeight: FontWeight.w900));
    }
    // 1단계: 리스트로 “전체” 느낌만 (진짜 그리드는 2단계)
    final show = rows.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...show.map((x) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '• ${x.name} · ${x.timeRaw}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        )),
        if (rows.length > show.length)
          Text(
            '…외 ${rows.length - show.length}개',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black.withValues(alpha: 0.55)),
          ),
      ],
    );
  }
}