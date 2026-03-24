import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

import 'dept_model.dart';
import 'dept_roadmap_data.dart';
import 'dept_roadmap_model.dart';

class DeptRoadmapScreen extends StatelessWidget {
  final DeptInfo dept;
  const DeptRoadmapScreen({super.key, required this.dept});

  @override
  Widget build(BuildContext context) {
    final rm = deptRoadmaps[dept.id] ?? defaultRoadmapFor(dept.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title:
            const Text('전과·로드맵', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          _HeaderCard(deptName: dept.name, roadmap: rm),
          const SizedBox(height: 12),
          if (rm.suggestedTransfers.isNotEmpty) ...[
            _SectionTitle(title: '추천 전과 후보', subtitle: '전과 100% 가능 컨셉 · 연결 전공'),
            const SizedBox(height: 10),
            _TransfersCard(items: rm.suggestedTransfers),
            const SizedBox(height: 14),
          ],
          _SectionTitle(title: '학기별 로드맵', subtitle: '학기/방학 단위로 “할 일”을 쪼개자'),
          const SizedBox(height: 10),
          ...rm.timeline.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TimelineCard(sem: s),
              )),
          const SizedBox(height: 6),
          _SectionTitle(title: '팁', subtitle: '평가/전과/성과에 실제로 도움되는 것'),
          const SizedBox(height: 10),
          _TipsCard(tips: rm.tips),
        ],
      ),
    );
  }
}

/* =========================
   UI
========================= */

class _HeaderCard extends StatelessWidget {
  final String deptName;
  final DeptRoadmap roadmap;

  const _HeaderCard({required this.deptName, required this.roadmap});

  @override
  Widget build(BuildContext context) {
    final transferText = roadmap.transferOpen ? '전과 가능(100%) 컨셉' : '전과 제한';

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.paejaeBlue.withValues(alpha: 0.92),
              AppColors.paejaeBlue.withValues(alpha: 0.60),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(text: deptName, icon: Icons.school_rounded),
                _Chip(text: transferText, icon: Icons.swap_horiz_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              roadmap.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              roadmap.subtitle,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          title,
          style: t.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.paejaeNavy,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.paejaeNavy.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransfersCard extends StatelessWidget {
  final List<String> items;
  const _TransfersCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((x) => _Pill(text: x)).toList(),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final SemesterRoadmap sem;
  const _TimelineCard({required this.sem});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sem.label,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          ...sem.steps.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StepRow(step: s),
              )),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final RoadmapStep step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    final p = step.priority.clamp(1, 5);
    final pText = 'P$p';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.paejaeBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(step.icon, color: AppColors.paejaeBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Text(
                      pText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.paejaeNavy.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
                ],
              ),
              if (step.note != null) ...[
                const SizedBox(height: 4),
                Text(
                  step.note!,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;
  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map((x) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.paejaeNavy
                                  .withValues(alpha: 0.75))),
                      Expanded(
                        child: Text(
                          x,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                            color: AppColors.paejaeNavy.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.paejaeNavy.withValues(alpha: 0.78)),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
