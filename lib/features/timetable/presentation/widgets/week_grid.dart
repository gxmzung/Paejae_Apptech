// lib/features/timetable/presentation/widgets/week_grid.dart
import 'package:flutter/material.dart';
import '../../domain/lecture_row.dart';
import '../../domain/lecture_meeting.dart';

class WeekGrid extends StatelessWidget {
  final List<LectureRow> rows;
  final int minMin;
  final int maxMin;
  final double hourHeight;
  final double dayWidth; // “희망값” (부모가 좁으면 자동으로 줄여서 overflow 방지)
  final bool emptyHint;

  const WeekGrid({
    super.key,
    required this.rows,
    required this.minMin,
    required this.maxMin,
    required this.hourHeight,
    required this.dayWidth,
    required this.emptyHint,
  });

  static const _days = ['월', '화', '수', '목', '금'];

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (maxMin - minMin).clamp(1, 24 * 60);
    final gridHeight = (totalMinutes / 60.0) * hourHeight;

    return LayoutBuilder(
      builder: (context, c) {
        // ✅ 부모 폭이 좁으면 dayWidth를 자동 축소해서 헤더/그리드가 overflow 안 나게
        final usable = (c.maxWidth.isFinite ? c.maxWidth : (52 + dayWidth * 5));
        final autoDayW = ((usable - 52) / 5).clamp(72.0, dayWidth);
        final effectiveDayW = autoDayW;

        if (rows.isEmpty && emptyHint) {
          return _EmptyGrid(height: gridHeight, dayWidth: effectiveDayW);
        }

        final blocks = <_Block>[];
        for (final r in rows) {
          blocks.addAll(_blocksFromRow(r));
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                _Header(dayWidth: effectiveDayW),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      height: gridHeight,
                      child: Stack(
                        children: [
                          _GridBackground(
                            minMin: minMin,
                            maxMin: maxMin,
                            hourHeight: hourHeight,
                            dayWidth: effectiveDayW,
                          ),
                          ...blocks.map((b) => _LectureBlockWidget(
                            block: b,
                            minMin: minMin,
                            hourHeight: hourHeight,
                            dayWidth: effectiveDayW,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_Block> _blocksFromRow(LectureRow r) {
    final out = <_Block>[];

    // ✅ meetings 기반 (가장 정확)
    if (r.meetings.isNotEmpty) {
      for (final m in r.meetings) {
        if (m.dayIndex < 0 || m.dayIndex > 4) continue; // 월~금만 표시

        final s = m.startMin.clamp(minMin, maxMin);
        final e = m.endMin.clamp(minMin, maxMin);
        if (e <= s) continue;

        out.add(_Block(
          dayIndex: m.dayIndex,
          startMin: s,
          endMin: e,
          title: r.name,
          room: (m.room.isNotEmpty ? m.room : r.room),
          professor: r.professor,
        ));
      }
      return out;
    }

    // fallback(안전)
    return out;
  }
}

/* ---------- UI PARTS ---------- */

class _Header extends StatelessWidget {
  final double dayWidth;
  const _Header({required this.dayWidth});

  static const _days = ['월', '화', '수', '목', '금'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 52),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: List.generate(_days.length, (i) {
          return SizedBox(
            width: dayWidth,
            child: Center(
              child: Text(_days[i], style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          );
        }),
      ),
    );
  }
}

class _GridBackground extends StatelessWidget {
  final int minMin;
  final int maxMin;
  final double hourHeight;
  final double dayWidth;

  const _GridBackground({
    required this.minMin,
    required this.maxMin,
    required this.hourHeight,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = ((maxMin - minMin) / 60).ceil();

    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Column(
            children: List.generate(totalHours + 1, (i) {
              final hour = (minMin ~/ 60) + i;
              return SizedBox(
                height: hourHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Row(
                children: List.generate(5, (_) {
                  return Container(
                    width: dayWidth,
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black.withOpacity(0.06))),
                    ),
                  );
                }),
              ),
              Column(
                children: List.generate(totalHours + 1, (_) {
                  return Container(
                    height: hourHeight,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LectureBlockWidget extends StatelessWidget {
  final _Block block;
  final int minMin;
  final double hourHeight;
  final double dayWidth;

  const _LectureBlockWidget({
    required this.block,
    required this.minMin,
    required this.hourHeight,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final top = ((block.startMin - minMin) / 60) * hourHeight;
    final height = ((block.endMin - block.startMin) / 60) * hourHeight;

    return Positioned(
      left: 52 + block.dayIndex * dayWidth + 6,
      top: top + 6,
      width: dayWidth - 12,
      height: height.clamp(52, 9999),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.withOpacity(0.25)),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  block.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (block.room.isNotEmpty)
                Text(
                  block.room,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black.withOpacity(0.65)),
                ),
              if (block.professor.isNotEmpty)
                Text(
                  block.professor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black.withOpacity(0.55)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  final double height;
  final double dayWidth;

  const _EmptyGrid({required this.height, required this.dayWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 44,
      child: Center(
        child: Text(
          '아직 담긴 과목이 없어요.\n과목을 추가해줘!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

/* ---------- MODEL ---------- */

class _Block {
  final int dayIndex;
  final int startMin;
  final int endMin;
  final String title;
  final String room;
  final String professor;

  const _Block({
    required this.dayIndex,
    required this.startMin,
    required this.endMin,
    required this.title,
    required this.room,
    required this.professor,
  });
}