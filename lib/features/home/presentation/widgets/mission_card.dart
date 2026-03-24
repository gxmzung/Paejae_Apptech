import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/config/theme/app_theme.dart';

enum MissionStatus { ready, running, done }

class MissionCard extends StatefulWidget {
  const MissionCard({super.key});

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  static const int totalSeconds = 600; // 10분
  int remainingSeconds = totalSeconds;
  MissionStatus status = MissionStatus.ready;
  Timer? timer;

  double get progress => 1 - (remainingSeconds / totalSeconds);

  void startMission() {
    setState(() {
      status = MissionStatus.running;
      remainingSeconds = totalSeconds;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        t.cancel();
        setState(() => status = MissionStatus.done);
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  String get timeText {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              AppTheme.paejaeBlue.withValues(alpha: 0.10),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border:
              Border.all(color: AppTheme.paejaeBlue.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.paejaeBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run_rounded,
                          size: 16, color: AppTheme.paejaeBlue),
                      SizedBox(width: 6),
                      Text('러닝 미션',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.paejaeBlue)),
                    ],
                  ),
                ),
                const Spacer(),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(170, 170),
                      painter: _CircleProgressPainter(progress),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status == MissionStatus.done ? '완료!' : timeText,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10분 러닝',
                          style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '10분 안에 러닝을 완료하면 포인트 보너스!',
              style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.62),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: status == MissionStatus.ready ? startMission : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.paejaeBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  status == MissionStatus.ready
                      ? '미션 시작'
                      : status == MissionStatus.running
                          ? '러닝 중...'
                          : '미션 완료 🎉',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MissionStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final map = {
      MissionStatus.ready: ('READY', Colors.black.withValues(alpha: 0.5)),
      MissionStatus.running: ('RUNNING', const Color(0xFF38BDF8)),
      MissionStatus.done: ('DONE', const Color(0xFF22C55E)),
    };
    final data = map[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.$2.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: data.$2.withValues(alpha: 0.22)),
      ),
      child: Text(
        data.$1,
        style: TextStyle(
            color: data.$2,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2),
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  _CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = AppTheme.paejaeBlue
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
