// lib/features/timetable/presentation/widgets/week_grid_painted.dart
import 'package:flutter/material.dart';
import '../../domain/lecture_row.dart';
import '../../domain/time_parsers.dart';

class WeekGridPainted extends StatelessWidget {
  final List<LectureRow> rows;
  final int minMin;
  final int maxMin;
  final double hourHeight;
  final double dayWidth;
  final bool emptyHint;

  const WeekGridPainted({
    super.key,
    required this.rows,
    required this.minMin,
    required this.maxMin,
    required this.hourHeight,
    required this.dayWidth,
    required this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (maxMin - minMin).clamp(1, 24 * 60);
    final gridHeight = (totalMinutes / 60.0) * hourHeight;
    final width = 52 + (dayWidth * 5);

    if (rows.isEmpty && emptyHint) {
      return _Empty(height: gridHeight + 44);
    }

    final blocks = <_Block>[];
    for (final r in rows) {
      final meetings = TimetableParsers.explodeMeetings(day: r.day, time: r.time);
      for (final m in meetings) {
        final s = m.startMin.clamp(minMin, maxMin);
        final e = m.endMin.clamp(minMin, maxMin);
        if (e <= s) continue;
        blocks.add(_Block(
          dayIndex: m.dayIndex,
          startMin: s,
          endMin: e,
          title: r.name,
          room: r.room,
          professor: r.professor,
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: width,
            height: gridHeight + 44,
            child: CustomPaint(
              painter: _GridPainter(
                minMin: minMin,
                maxMin: maxMin,
                hourHeight: hourHeight,
                dayWidth: dayWidth,
                blocks: blocks,
                textScale: MediaQuery.textScaleFactorOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int minMin;
  final int maxMin;
  final double hourHeight;
  final double dayWidth;
  final List<_Block> blocks;
  final double textScale;

  _GridPainter({
    required this.minMin,
    required this.maxMin,
    required this.hourHeight,
    required this.dayWidth,
    required this.blocks,
    required this.textScale,
  });

  static const days = ['월', '화', '수', '목', '금'];

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);

    final line = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    // header bg
    final headerBg = Paint()..color = Colors.black.withOpacity(0.03);
    canvas.drawRect(const Rect.fromLTWH(0, 0, double.infinity, 44), headerBg);

    // header bottom line
    canvas.drawLine(const Offset(0, 44), Offset(size.width, 44), line);

    // day labels
    final dayTextStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 12 * textScale,
      color: Colors.black.withOpacity(0.85),
    );

    for (int i = 0; i < 5; i++) {
      final x = 52 + i * dayWidth;
      // vertical day line
      canvas.drawLine(Offset(x, 44), Offset(x, size.height), line);

      final tp = TextPainter(
        text: TextSpan(text: days[i], style: dayTextStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: dayWidth);
      tp.paint(canvas, Offset(x + (dayWidth - tp.width) / 2, 12));
    }
    // right border
    canvas.drawLine(Offset(52 + 5 * dayWidth, 44), Offset(52 + 5 * dayWidth, size.height), line);

    // hour horizontal lines + labels
    final totalHours = ((maxMin - minMin) / 60.0).ceil().clamp(1, 24);
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 11 * textScale,
      color: Colors.black.withOpacity(0.55),
    );

    for (int i = 0; i <= totalHours; i++) {
      final y = 44 + i * hourHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);

      final hour = (minMin ~/ 60) + i;
      final tp = TextPainter(
        text: TextSpan(text: '${hour.toString().padLeft(2, '0')}:00', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 52);
      tp.paint(canvas, Offset(6, y + 6));
    }

    // blocks
    for (final b in blocks) {
      final top = 44 + ((b.startMin - minMin) / 60.0) * hourHeight + 6;
      final h = (((b.endMin - b.startMin) / 60.0) * hourHeight - 12).clamp(34.0, 9999.0);
      final left = 52 + (b.dayIndex * dayWidth) + 6;
      final w = dayWidth - 12;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, w, h),
        const Radius.circular(14),
      );

      final fill = Paint()..color = Colors.blue.withOpacity(0.10);
      final stroke = Paint()
        ..color = Colors.blue.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);

      final titleStyle = TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 12 * textScale,
        color: Colors.black.withOpacity(0.92),
      );
      final subStyle = TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 11 * textScale,
        color: Colors.black.withOpacity(0.60),
      );

      final text = [
        b.title,
        if (b.room.trim().isNotEmpty) b.room,
        if (b.professor.trim().isNotEmpty) b.professor,
      ].join('\n');

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: titleStyle,
          children: [
            // 첫줄 제외하고 서브 느낌
            if (text.contains('\n'))
              TextSpan(
                text: '',
                style: subStyle,
              ),
          ],
        ),
        textDirection: TextDirection.ltr,
        maxLines: 4,
        ellipsis: '…',
      )..layout(maxWidth: w - 16);

      tp.paint(canvas, Offset(left + 10, top + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) {
    return old.blocks != blocks ||
        old.minMin != minMin ||
        old.maxMin != maxMin ||
        old.hourHeight != hourHeight ||
        old.dayWidth != dayWidth ||
        old.textScale != textScale;
  }
}

class _Block {
  final int dayIndex;
  final int startMin;
  final int endMin;
  final String title;
  final String room;
  final String professor;

  _Block({
    required this.dayIndex,
    required this.startMin,
    required this.endMin,
    required this.title,
    required this.room,
    required this.professor,
  });
}

class _Empty extends StatelessWidget {
  final double height;
  const _Empty({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Text(
        '아직 담긴 과목이 없어요.\n시간표 담기에서 과목을 추가해줘!',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black.withOpacity(0.65)),
      ),
    );
  }
}