import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

import 'dept_model.dart';
import 'dept_roadmap_screen.dart';

class DeptDetailScreen extends StatelessWidget {
  final DeptInfo dept;
  const DeptDetailScreen({super.key, required this.dept});

  @override
  Widget build(BuildContext context) {
    final diff = dept.difficulty ??
        const DeptDifficulty(
          level: 3,
          comment: '보통 난이도예요. 꾸준히 따라가면 충분히 할 만해요.',
        );

    final opt = dept.options ??
        const DeptOptions(
          transfer: true,
          doubleMajor: true,
          minor: true,
          note: '배재대학교는 전과 100% 가능 컨셉! (결과물/계획서가 있으면 더 유리)',
        );

    final learn = dept.learnWhat ??
        const [
          '전공 기초 개념을 탄탄히 다져요.',
          '실습/프로젝트로 실전 감각을 키워요.',
          '현장/산업 이해를 통해 진로를 확장해요.',
        ];

    final jobs = dept.jobs ?? dept.careers;

    final culture = dept.culture ??
        const [
          '팀플/과제가 종종 있어요.',
          '전공 몰입도는 사람마다 차이가 있어요.',
          '선후배/동기 분위기는 다양해서 “맞는 무리”를 찾으면 좋아요.',
        ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          // =========================
          // 상단 카드(기존 느낌 유지)
          // =========================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                _Mascot(asset: dept.mascotAsset, size: 76),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dept.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(dept.category.icon,
                              size: 16, color: AppColors.paejaeBlue),
                          const SizedBox(width: 6),
                          Text(
                            dept.category.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.paejaeNavy.withValues(alpha: 0.70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: dept.tags.map((t) => _TagPill(text: t)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 전과 100% 배너 (고정)
          // =========================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.autorenew_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '배재대학교는 전과 100% 가능!\n학과 선택은 “결과물/계획”으로 증명하면 돼',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // 5줄 소개(기존)
          // =========================
          _SectionCard(
            tint: AppColors.paejaeBlue.withValues(alpha: 0.08),
            border: AppColors.paejaeBlue.withValues(alpha: 0.12),
            title: '소개',
            children: dept.intro5.map((line) => _Bullet(line)).toList(),
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 1) 뭐 배우지?
          // =========================
          _SectionCard(
            title: '이 학과 나오면 뭐 배우지?',
            children: learn.map((e) => _Bullet(e)).toList(),
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 2) 난이도
          // =========================
          _SectionCard(
            title: '수업 난이도 어때?',
            children: [
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < diff.level ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.paejaeBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                diff.comment,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 3) 취업
          // =========================
          _SectionCard(
            title: '어디로 취업하지?',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: jobs.map((e) => _TagPill(text: e)).toList(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 4) 복수/전과/부전공
          // =========================
          _SectionCard(
            title: '복수 / 전과 / 부전공 가능성은?',
            children: [
              _CheckRow(label: '전과', ok: opt.transfer),
              const SizedBox(height: 8),
              _CheckRow(label: '복수전공', ok: opt.doubleMajor),
              const SizedBox(height: 8),
              _CheckRow(label: '부전공', ok: opt.minor),
              const SizedBox(height: 10),
              Text(
                opt.note,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =========================
          // ✅ 5) 분위기
          // =========================
          _SectionCard(
            title: '이 학과 사람들 분위기는?',
            children: culture.map((e) => _Bullet(e)).toList(),
          ),

          const SizedBox(height: 16),

          // =========================
          // 액션(기존 유지 + 설명 강화)
          // =========================
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.route_rounded,
                  title: '전과·로드맵 보기',
                  subtitle: '학기별 해야 할 일 + 추천 전과 후보까지 한 번에',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DeptRoadmapScreen(dept: dept)),
                  ),
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  icon: Icons.open_in_new_rounded,
                  title: '학교 홈페이지 보기 (추후 연결)',
                  subtitle: '학과 링크 붙이면 바로 열 수 있어',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('다음 단계에서 학과 링크를 연결하자!')),
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

/* =========================
   Reusable section widgets
========================= */

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// 옵션: 특정 섹션만 살짝 틴트 주고 싶을 때
  final Color? tint;
  final Color? border;

  const _SectionCard({
    required this.title,
    required this.children,
    this.tint,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tint ?? Colors.white.withValues(alpha: 0.92);
    final bd = border ?? Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: bd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.paejaeNavy.withValues(alpha: 0.75),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: AppColors.paejaeNavy.withValues(alpha: 0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool ok;
  const _CheckRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ok
                ? AppColors.paejaeBlue.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            ok ? Icons.check_rounded : Icons.close_rounded,
            color: ok ? AppColors.paejaeBlue : AppColors.paejaeNavy.withValues(alpha: 0.35),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          ok ? '가능' : '미정',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: ok
                ? AppColors.paejaeBlue
                : AppColors.paejaeNavy.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

/* =========================
   Existing style widgets (kept)
========================= */

class _Mascot extends StatelessWidget {
  final String asset;
  final double size;
  const _Mascot({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/brand/paejae_logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill({required this.text});

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
          color: AppColors.paejaeNavy.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.paejaeBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.paejaeNavy.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}