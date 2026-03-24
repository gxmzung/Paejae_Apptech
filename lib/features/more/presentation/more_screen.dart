import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/timetable/presentation/timetable_screen.dart';
import 'package:apptech_flutter/features/more/presentation/campus_guide_web_screen.dart';
import 'package:apptech_flutter/features/more/presentation/credits_screen.dart';
import 'package:apptech_flutter/features/more/presentation/gpa_calculator_screen.dart';
import 'package:apptech_flutter/features/dept/presentation/dept_wiki_screen.dart';
import 'package:apptech_flutter/features/academic/academic_calendar_screen.dart';
import 'package:apptech_flutter/features/more/presentation/widget_settings_screen.dart';
import 'package:apptech_flutter/features/lost_found/lost_found_report_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const String _kNasomKey = 'nasom_points_v1';
  static const int _kMaxSafePoints = 9000000000000000000;

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _fmtPoints(int v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(1)}B';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  Future<int> _loadPoints() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getInt(_kNasomKey) ?? 120;
    return raw.clamp(0, _kMaxSafePoints);
  }

  Future<void> _resetAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('초기화할까?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          '포인트/걸음기록 등 로컬 데이터를 초기화해요.',
          style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.paejaeBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('초기화', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final sp = await SharedPreferences.getInstance();
    await sp.clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초기화 완료! 앱을 다시 실행해보자.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title: const Text('더보기', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          FutureBuilder<int>(
            future: _loadPoints(),
            builder: (_, snap) {
              final points = snap.data ?? 0;
              return _ProfileHeader(pointsText: _fmtPoints(points));
            },
          ),
          const SizedBox(height: 14),
          _GridCard(
            children: [
              _GridItem(
                icon: Icons.calendar_month_rounded,
                label: '시간표',
                onTap: () => _go(context, const TimeTableScreen()),
              ),
              _GridItem(
                icon: Icons.event_note_rounded,
                label: '학사일정',
                onTap: () => _go(context, AcademicCalendarScreen()),
              ),
              _GridItem(
                icon: Icons.calculate_rounded,
                label: '학점계산',
                onTap: () => _go(context, const GpaCalculatorScreen()),
              ),
              _GridItem(
                icon: Icons.menu_book_rounded,
                label: '학과백과',
                onTap: () => _go(context, const DeptWikiScreen()),
              ),
              _GridItem(
                icon: Icons.map_rounded,
                label: '교내지도',
                onTap: () => _go(context, const CampusGuideWebScreen()),
              ),
              _GridItem(
                icon: Icons.inventory_2_rounded,
                label: '분실물 신고',
                onTap: () => _go(context, const LostFoundReportScreen()),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GraySection(
            title: '앱',
            tiles: [
              _LineTile(
                icon: Icons.lock_outline_rounded,
                title: '잠금화면 위젯 설정',
                subtitle: '위젯 미리보기와 표시 구성을 조정',
                onTap: () => _go(context, const WidgetSettingsScreen()),
              ),
              _LineTile(
                icon: Icons.restart_alt_rounded,
                title: '로컬 데이터 초기화',
                subtitle: '포인트/걸음/캐시를 초기화',
                danger: true,
                onTap: () => _resetAll(context),
              ),
              _LineTile(
                icon: Icons.groups_rounded,
                title: '만든 사람들',
                onTap: () => _go(context, const CreditsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String pointsText;

  const _ProfileHeader({required this.pointsText});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.paejaeNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '로컬 프로필',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.paejaeNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '이 기기에 저장된 포인트와 기록을 사용해요',
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$pointsText P',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final List<Widget> children;
  const _GridCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          childAspectRatio: 2.9,
          children: children,
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.paejaeBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.paejaeBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.paejaeNavy,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GraySection extends StatelessWidget {
  final String title;
  final List<_LineTile> tiles;
  const _GraySection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              ),
            ),
          ),
          ...tiles,
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _LineTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final titleColor = danger ? Colors.red.shade700 : AppColors.paejaeNavy;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: danger ? Colors.red.shade700 : AppColors.paejaeBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}