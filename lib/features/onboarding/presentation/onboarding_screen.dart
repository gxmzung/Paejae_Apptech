import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _requestStepPermission() async {
    if (kIsWeb) return;

    // Android: activity recognition
    // iOS: request 가능하지만 실제 설정/Health 영향이 있어 “안내+설정 버튼” 병행
    await Permission.activityRecognition.request();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _OnbPage(
        icon: Icons.school_rounded,
        title: '배재대 정식 앱 퀄\n활동/포인트',
        desc: '걸음 기반으로 거리·칼로리를 계산하고\n1000걸음마다 포인트가 자동 지급돼요.',
      ),
      _OnbPage(
        icon: Icons.analytics_rounded,
        title: '주간/월간 통계',
        desc: '저장된 걸음 데이터로\n주간·월간 분석을 깔끔하게 보여줘요.',
      ),
      _OnbPage(
        icon: Icons.lock_rounded,
        title: '권한이 필요한 이유',
        desc: '걸음 권한이 있어야\n홈/통계/포인트가 제대로 동작해요.',
        extra: _PermissionCard(
          onRequest: _requestStepPermission,
          onOpenSettings: () => openAppSettings(),
          isIOS: !kIsWeb && Platform.isIOS,
          isAndroid: !kIsWeb && Platform.isAndroid,
        ),
      ),
    ];

    final isLast = _index == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _TopBar(
              index: _index,
              total: pages.length,
              onSkip: widget.onComplete,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: _PrimaryButton(
                      label: isLast ? '시작하기' : '다음',
                      icon: isLast ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                      onTap: () async {
                        if (!isLast) {
                          await _page.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          );
                          return;
                        }
                        widget.onComplete();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onSkip;

  const _TopBar({
    required this.index,
    required this.total,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final p = (index + 1) / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: p.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.paejaeBlue.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.paejaeNavy.withValues(alpha: 0.70),
            ),
            child: const Text('건너뛰기', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _OnbPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Widget? extra;

  const _OnbPage({
    required this.icon,
    required this.title,
    required this.desc,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        Container(
          height: 66,
          width: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.paejaeBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, size: 34, color: AppColors.paejaeBlue),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1.15),
        ),
        const SizedBox(height: 10),
        Text(
          desc,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            height: 1.35,
            color: AppColors.paejaeNavy.withValues(alpha: 0.70),
          ),
        ),
        if (extra != null) ...[
          const SizedBox(height: 14),
          extra!,
        ],
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final Future<void> Function() onRequest;
  final VoidCallback onOpenSettings;
  final bool isIOS;
  final bool isAndroid;

  const _PermissionCard({
    required this.onRequest,
    required this.onOpenSettings,
    required this.isIOS,
    required this.isAndroid,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('권한 안내', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            isAndroid
                ? '• Android: “신체 활동(활동 인식)” 권한 필요'
                : isIOS
                ? '• iOS: “동작 및 피트니스” + 필요 시 “건강(Health)” 허용'
                : '• 권한이 필요해요',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: AppColors.paejaeNavy.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryButton(
                  label: '권한 요청',
                  icon: Icons.verified_user_rounded,
                  onTap: () => onRequest(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryButton(
                  label: '설정',
                  icon: Icons.settings_rounded,
                  onTap: onOpenSettings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.paejaeBlue.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.paejaeBlue),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeBlue)),
          ],
        ),
      ),
    );
  }
}
