import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/config/theme/app_theme.dart';

class PointCard extends StatelessWidget {
  const PointCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.paejaeBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  const Icon(Icons.savings_rounded, color: AppTheme.paejaeBlue),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘 적립 포인트',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('미션/걸음으로 자동 적립',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            const Text(
              '+120P',
              style: TextStyle(
                color: AppTheme.paejaeBlue,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
