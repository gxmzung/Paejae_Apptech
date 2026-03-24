import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apptech_flutter/core/api/app_state.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class TodayActivityCard extends StatelessWidget {
  const TodayActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 제목 =====
          Row(
            children: [
              const Text(
                '오늘 활동',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.paejaeNavy,
                ),
              ),
              const Spacer(),
              if (app.isDailyPointMaxed)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.paejaeBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'MAX',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppColors.paejaeBlue,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ===== 걸음 수 =====
          Text(
            '${app.steps.toString()} / 10,000 보',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 6),

          // ===== 진행 바 =====
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: app.todayProgress,
              minHeight: 10,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(
                app.isDailyPointMaxed ? Colors.green : AppColors.paejaeBlue,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ===== 포인트 + 칼로리 =====
          Row(
            children: [
              _MiniStat(
                icon: Icons.monetization_on_rounded,
                label: '오늘 포인트',
                value: '${app.todayPointBySteps}P / 100P',
              ),
              const SizedBox(width: 14),
              _MiniStat(
                icon: Icons.local_fire_department_rounded,
                label: '소모 칼로리',
                value: '${app.todayCalories.toStringAsFixed(1)} kcal',
              ),
            ],
          ),

          if (app.isDailyPointMaxed) ...[
            const SizedBox(height: 10),
            Text(
              '오늘 포인트를 모두 획득했어요 🎉\n챌린지로 추가 포인트를 얻어보세요!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: AppColors.paejaeNavy.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.paejaeBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.paejaeBlue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
