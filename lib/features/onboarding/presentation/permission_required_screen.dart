import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';

class PermissionRequiredScreen extends StatefulWidget {
  final VoidCallback onDone;
  final VoidCallback onSkip;

  const PermissionRequiredScreen({
    super.key,
    required this.onDone,
    required this.onSkip,
  });

  @override
  State<PermissionRequiredScreen> createState() => _PermissionRequiredScreenState();
}

class _PermissionRequiredScreenState extends State<PermissionRequiredScreen> {
  bool _requesting = false;

  Future<void> _request() async {
    if (kIsWeb) return;

    setState(() => _requesting = true);
    try {
      await Permission.activityRecognition.request();
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && Platform.isIOS;
    final isAndroid = !kIsWeb && Platform.isAndroid;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title: const Text('권한 안내', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            const SizedBox(height: 6),
            const Text(
              '걸음 권한이 필요해요',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              '걸음 수가 있어야 거리/칼로리/포인트 계산이 정확해지고\n통계(주간/월간)도 제대로 완성돼요.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: AppColors.paejaeNavy.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: 14),

            _Card(
              icon: Icons.analytics_rounded,
              title: '권한이 하는 일',
              lines: const [
                '• 홈: 오늘 걸음/거리/칼로리 표시',
                '• 포인트: 1000걸음당 자동 +10P',
                '• 통계: 주간/월간 분석 데이터 생성',
              ],
            ),
            const SizedBox(height: 12),

            if (isAndroid) ...[
              _Card(
                icon: Icons.security_rounded,
                title: 'Android',
                lines: const [
                  '“신체 활동(활동 인식)” 권한이 필요해요.',
                  '거부했어도 설정에서 다시 켤 수 있어요.',
                ],
              ),
              const SizedBox(height: 12),
            ],

            if (isIOS) ...[
              _Card(
                icon: Icons.favorite_rounded,
                title: 'iPhone에서 안 될 때',
                lines: const [
                  '1) 설정 > 개인정보 보호 및 보안 > 동작 및 피트니스',
                  '2) 설정 > 건강(Health) > 데이터 접근 및 기기 허용',
                  '이 앱이 허용되어야 걸음이 들어올 수 있어요.',
                ],
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _requesting ? null : _request,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.paejaeBlue,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _requesting
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          '권한 요청',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => openAppSettings(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.18)),
                      ),
                      child: const Center(
                        child: Text(
                          '설정으로 이동',
                          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeBlue),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onDone,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: const Center(
                  child: Text(
                    '완료했어요 → 계속',
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeNavy),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: widget.onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.paejaeNavy.withValues(alpha: 0.65),
              ),
              child: const Text('나중에 할게요 (제한 모드)', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _Card({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.paejaeBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                for (final s in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: AppColors.paejaeNavy.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
