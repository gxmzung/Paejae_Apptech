// lib/timetable/timetable_widgets.dart
import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import 'timetable_models.dart';

class CourseTile extends StatelessWidget {
  final Course course;
  final bool added;
  final VoidCallback onTap;

  const CourseTile({
    super.key,
    required this.course,
    required this.added,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: course.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.class_rounded, color: course.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.name,
                      style:
                          t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    '${course.professor} · ${course.credit}학점 · ${course.location}',
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: added
                    ? AppColors.paejaeBlue.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Text(
                added ? '담김' : '추가',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: added
                      ? AppColors.paejaeBlue
                      : AppColors.paejaeNavy.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimetableGrid extends StatelessWidget {
  final List<TimetableBlock> blocks;
  final int startHour; // e.g. 9
  final int endHour; // e.g. 19

  const TimetableGrid({
    super.key,
    required this.blocks,
    this.startHour = 9,
    this.endHour = 19,
  });

  static const _days = [
    WeekdayKR.mon,
    WeekdayKR.tue,
    WeekdayKR.wed,
    WeekdayKR.thu,
    WeekdayKR.fri
  ];

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(endHour - startHour, (i) => startHour + i);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final colW = w / 6; // 시간열 1 + 요일 5
        final rowH = 54.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // grid lines + headers
                Column(
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          SizedBox(width: colW, child: _HeaderCell('')),
                          ..._days.map((d) => SizedBox(
                              width: colW, child: _HeaderCell(d.label))),
                        ],
                      ),
                    ),
                    ...hours.map((h) {
                      return SizedBox(
                        height: rowH,
                        child: Row(
                          children: [
                            SizedBox(
                                width: colW,
                                child: _TimeCell(
                                    '${h.toString().padLeft(2, '0')}:00')),
                            ...List.generate(
                                5,
                                (_) =>
                                    SizedBox(width: colW, child: _BodyCell())),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

                // blocks
                ...blocks.map((b) {
                  final dayIdx = b.slot.day.index0;
                  final topMinutes = b.slot.startInMinutes - (startHour * 60);
                  final durMinutes =
                      b.slot.endInMinutes - b.slot.startInMinutes;

                  final top = 44 + (topMinutes / 60.0) * rowH; // header 44
                  final height = (durMinutes / 60.0) * rowH;
                  final left = colW * (dayIdx + 1);

                  return Positioned(
                    left: left + 4,
                    top: top + 4,
                    width: colW - 8,
                    height: height - 8,
                    child: _BlockCard(block: b),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class _TimeCell extends StatelessWidget {
  final String text;
  const _TimeCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.paejaeNavy.withValues(alpha: 0.65)),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          right: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final TimetableBlock block;
  const _BlockCard({required this.block});

  @override
  Widget build(BuildContext context) {
    final c = block.course;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.color.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(c.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
