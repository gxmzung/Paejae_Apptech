import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/missions/data/mission_repo.dart';
import 'package:apptech_flutter/features/missions/models/mission.dart';

class MissionsScreen extends StatefulWidget {
  final int stepsToday;
  const MissionsScreen({super.key, required this.stepsToday});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  SharedPreferences? _sp;
  List<DailyMission> _missions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _sp = await SharedPreferences.getInstance();
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await MissionRepo.loadTodayMissions(_sp!);
      if (!mounted) return;
      setState(() {
        _missions = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _missions = const [];
        _loading = false;
      });
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _toggleManual(DailyMission m) async {
    try {
      final next = await MissionRepo.toggleManual(_sp!, m);
      if (!mounted) return;
      setState(() => _missions = next);
    } catch (_) {
      _toast('처리 중 오류가 발생했어요.');
    }
  }

  Future<void> _claim(DailyMission m) async {
    try {
      final res = await MissionRepo.claim(_sp!, m, stepsToday: widget.stepsToday);
      final gained = res.gained;
      final next = res.missions;

      if (!mounted) return;
      setState(() => _missions = next);

      if (gained != null && gained > 0) {
        _toast('미션 보상 +${gained}P 🎉');
      } else {
        _toast('아직 조건이 부족해요. 조금만 더!');
      }
    } catch (_) {
      _toast('보상 수령에 실패했어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final safe = _missions;
    final total = safe.length;
    final completed = safe.where((m) => m.isDone(stepsToday: widget.stepsToday)).length;
    final claimed = safe.where((m) => m.claimed).length;

    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('오늘 미션', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          _MissionHeroHeader(
            stepsToday: widget.stepsToday,
            total: total,
            completed: completed,
            claimed: claimed,
            progress: progress,
          ),
          const SizedBox(height: 12),

          if (_loading) ...[
            _SkeletonCard(),
            _SkeletonCard(),
            _SkeletonCard(),
          ] else if (safe.isEmpty) ...[
            _WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('오늘 미션이 없어요',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    '미션 풀(템플릿)이 비어있거나 로드에 실패했을 수 있어요.\n'
                        'mission_repo.dart 템플릿을 확인해줘!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _load,
                      child: const Text('다시 불러오기'),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...safe.map((m) => _MissionCard(
              m: m,
              stepsToday: widget.stepsToday,
              onToggleManual: () => _toggleManual(m),
              onClaim: () => _claim(m),
              onOpenFeature: () {
                // 오픈 기능 미션은 "기능 화면을 열면 완료" 컨셉.
                // 실제 완료처리는 해당 기능 화면에서 MissionRepo.markFeatureDone(sp, key) 같은 방식으로 처리하면 가장 깔끔함.
                // 여기서는 UX만 정식앱처럼 안내.
                _toast('이 미션은 해당 기능을 열면 자동 완료돼요!');
              },
            )),
            const SizedBox(height: 6),
            _BottomHint(),
          ],
        ],
      ),
    );
  }
}

/* =========================
   프리미엄 히어로 헤더
========================= */

class _MissionHeroHeader extends StatelessWidget {
  final int stepsToday;
  final int total;
  final int completed;
  final int claimed;
  final double progress;

  const _MissionHeroHeader({
    required this.stepsToday,
    required this.total,
    required this.completed,
    required this.claimed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.paejaeBlue.withValues(alpha: 0.95),
              AppColors.paejaeBlue.withValues(alpha: 0.70),
              AppColors.paejaeBlue.withValues(alpha: 0.88),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -80, top: -70, child: _Blob(size: 240, alpha: 0.14)),
            Positioned(left: -80, bottom: -90, child: _Blob(size: 280, alpha: 0.12)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('오늘 미션 보드',
                          style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900, color: Colors.white)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Text(
                          '완료 $completed/$total · 수령 $claimed/$total',
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      children: [
                        _ProgressRing(progress: progress, centerTop: '${(progress * 100).round()}%', centerBottom: 'progress'),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('오늘 걸음: $stepsToday 보',
                                  style: t.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w900, color: Colors.white)),
                              const SizedBox(height: 6),
                              Text(
                                '미션을 완료하고 보상을 수령하면 포인트가 쌓여요.',
                                style: t.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: const [
                      _HeroChip(icon: Icons.bolt_rounded, text: '랜덤 미션 3~6개'),
                      SizedBox(width: 8),
                      _HeroChip(icon: Icons.card_giftcard_rounded, text: '완료 후 수령'),
                      SizedBox(width: 8),
                      _HeroChip(icon: Icons.safety_check_rounded, text: '중복 방지'),
                    ],
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

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

/* =========================
   미션 카드
========================= */

class _MissionCard extends StatelessWidget {
  final DailyMission m;
  final int stepsToday;

  final VoidCallback onToggleManual;
  final VoidCallback onClaim;
  final VoidCallback onOpenFeature;

  const _MissionCard({
    required this.m,
    required this.stepsToday,
    required this.onToggleManual,
    required this.onClaim,
    required this.onOpenFeature,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final done = m.isDone(stepsToday: stepsToday);
    final canClaim = done && !m.claimed;

    final icon = _typeIcon(m.t.type);
    final typeLabel = _typeLabel(m.t.type);
    final progressText = _progressText(m, stepsToday);

    final statusText = m.claimed
        ? '수령완료'
        : (done ? '완료됨' : '진행중');

    final statusColor = m.claimed
        ? Colors.green.shade700
        : (done ? AppColors.paejaeBlue : AppColors.paejaeNavy.withValues(alpha: 0.75));

    final statusBg = m.claimed
        ? Colors.green.withValues(alpha: 0.10)
        : (done ? AppColors.paejaeBlue.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.04));

    // 오른쪽 액션 버튼 UX
    Widget rightAction() {
      if (m.claimed) {
        return _MiniPill(text: '수령완료', color: Colors.green.shade700, bg: Colors.green.withValues(alpha: 0.10));
      }

      if (m.t.type == MissionType.manual) {
        // 수동: 체크/해제
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onToggleManual,
          child: _MiniPill(
            text: m.manualDone ? '체크됨' : '체크',
            color: AppColors.paejaeBlue,
            bg: AppColors.paejaeBlue.withValues(alpha: 0.12),
          ),
        );
      }

      if (m.t.type == MissionType.openFeature) {
        // 오픈기능: 안내 버튼
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onOpenFeature,
          child: _MiniPill(
            text: done ? '완료됨' : '열기',
            color: done ? AppColors.paejaeBlue : AppColors.paejaeNavy.withValues(alpha: 0.85),
            bg: done ? AppColors.paejaeBlue.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
          ),
        );
      }

      // steps: 기본은 수령/진행
      return _MiniPill(
        text: done ? '완료됨' : '진행중',
        color: done ? AppColors.paejaeBlue : AppColors.paejaeNavy.withValues(alpha: 0.75),
        bg: done ? AppColors.paejaeBlue.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.14)),
                ),
                child: Icon(icon, color: AppColors.paejaeBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.paejaeNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Badge(text: typeLabel),
                        const SizedBox(width: 6),
                        _Badge(text: '$statusText · +${m.t.reward}P', tone: statusColor, bg: statusBg),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              rightAction(),
            ],
          ),

          const SizedBox(height: 12),

          // 진행 텍스트
          Row(
            children: [
              Expanded(
                child: Text(
                  progressText,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.70),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 수령 CTA
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: canClaim ? onClaim : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: canClaim ? AppColors.paejaeBlue : Colors.black.withValues(alpha: 0.08),
                    foregroundColor: canClaim ? Colors.white : AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                  child: Text(
                    m.claimed ? '수령완료' : (canClaim ? '보상 받기' : '조건 부족'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 미니 진행바(steps에만)
          if (m.t.type == MissionType.steps && m.t.stepTarget != null && m.t.stepTarget! > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ((stepsToday / m.t.stepTarget!).clamp(0.0, 1.0)),
                minHeight: 10,
                backgroundColor: Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _typeIcon(MissionType type) {
    switch (type) {
      case MissionType.steps:
        return Icons.directions_walk_rounded;
      case MissionType.openFeature:
        return Icons.auto_awesome_rounded;
      case MissionType.manual:
        return Icons.checklist_rounded;
    }
  }

  static String _typeLabel(MissionType type) {
    switch (type) {
      case MissionType.steps:
        return '걸음';
      case MissionType.openFeature:
        return '기능';
      case MissionType.manual:
        return '체크';
    }
  }

  static String _progressText(DailyMission m, int stepsToday) {
    switch (m.t.type) {
      case MissionType.steps:
        final target = m.t.stepTarget ?? 0;
        return '진행: $stepsToday / $target 보';
      case MissionType.openFeature:
        return m.featureDone ? '완료됨' : '해당 기능을 열면 자동 완료돼요.';
      case MissionType.manual:
        return m.manualDone ? '체크 완료!' : '체크 버튼을 눌러 완료 처리할 수 있어요.';
    }
  }
}

/* =========================
   하단 힌트
========================= */

class _BottomHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Text(
        'Tip) “기능 미션”은 해당 기능 화면을 열 때 자동 완료되도록 연결하면 정식 앱 느낌이 확 살아나요.\n'
            '원하면 내가 각 기능 화면에 1줄짜리 자동완료 훅도 같이 붙여줄게.',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.paejaeNavy.withValues(alpha: 0.70),
          height: 1.35,
        ),
      ),
    );
  }
}

/* =========================
   공용 UI
========================= */

class _Badge extends StatelessWidget {
  final String text;
  final Color? tone;
  final Color? bg;

  const _Badge({required this.text, this.tone, this.bg});

  @override
  Widget build(BuildContext context) {
    final c = tone ?? AppColors.paejaeNavy.withValues(alpha: 0.80);
    final b = bg ?? Colors.black.withValues(alpha: 0.04);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: b,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, color: c, fontSize: 12)),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;

  const _MiniPill({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 12),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double alpha;
  const _Blob({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final String centerTop;
  final String centerBottom;

  const _ProgressRing({
    required this.progress,
    required this.centerTop,
    required this.centerBottom,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.92)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerTop,
                  style: t.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  )),
              const SizedBox(height: 2),
              Text(centerBottom,
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.0,
                  )),
            ],
          )
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Container(height: 14, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 10),
                Container(height: 12, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
