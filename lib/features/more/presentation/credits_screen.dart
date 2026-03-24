import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('만든 사람들', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          // ===== HERO =====
          _HeroPortfolio(t: t),

          const SizedBox(height: 14),

          // ===== QUICK STATS =====
          _QuickStats(t: t),

          const SizedBox(height: 18),

          // ===== SECTION TITLE =====
          Row(
            children: [
              Text(
                'DEVELOPMENT TEAM',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: AppColors.paejaeNavy.withOpacity(0.55),
                ),
              ),
              const Spacer(),
              const _TinyBadge(text: '26학번', icon: Icons.auto_awesome_rounded),
            ],
          ),
          const SizedBox(height: 10),

          // ===== MEMBERS =====
          _MemberProCard(
            icon: Icons.laptop_mac_rounded,
            name: '이영준',
            dept: '컴퓨터공학과 · 26학번',
            headerBadge: const _TinyBadge(
              text: 'DEVELOPER',
              icon: Icons.workspace_premium_rounded,
            ),
            rolePills: const [
              '총괄 개발',
              '아키텍처',
              '상태관리',
              '보안',
              '데이터/저장소',
              '빌드/배포',
            ],
            highlightsTitle: 'Tech Stack (주요 사용 기술)',
            highlights: const [
              'Flutter(Dart) · Material UI · 커스텀 컴포넌트/테마(AppColors)',
              'State: Provider/ChangeNotifier · Navigator 라우팅 구조',
              'Data: SharedPreferences 로컬 저장(포인트/스트릭/체크인/로그)',
              'Device: Pedometer 스트림 · Permission Handler(Android/iOS 권한)',
              'Logic: 포인트 Ledger, 보상/중복방지, 혼잡 예측/체크인 모델링',
            ],
          ),
          const SizedBox(height: 12),

          _MemberProCard(
            icon: Icons.photo_camera_rounded,
            name: '최승완',
            dept: '광고사진촬영학과 · 26학번',
            headerBadge: const _TinyBadge(
              text: 'CONTENT',
              icon: Icons.video_camera_back_rounded,
            ),
            rolePills: const [
              '카페 사진 촬영',
              '음식 촬영',
              '비주얼 에셋',
            ],
            highlightsTitle: '콘텐츠 기여',
            highlights: const [
              '교내 카페/푸드트럭/식당 등 “실사용” 사진 촬영 및 선별',
              '음식/메뉴 촬영으로 화면용 비주얼 에셋 제작',
              '앱 톤앤매너에 맞춰 이미지 퀄리티/일관성 관리',
            ],
          ),
          const SizedBox(height: 12),

          _MemberProCard(
            icon: Icons.public_rounded,
            name: '최민성',
            dept: 'IT경영학과 · 26학번',
            headerBadge: const _TinyBadge(
              text: 'OPS',
              icon: Icons.fact_check_rounded,
            ),
            rolePills: const [
              '구글플레이 문서',
              '자료조사',
              'QA',
              '운영관리',
              '인스타 관리',
            ],
            highlightsTitle: '운영·문서·QA 기여',
            highlights: const [
              '구글 플레이 출시 시 필요한 문서 작성/정리(스토어 등록용 자료 포함)',
              '학교/학과/서비스 정보 자료 조사 및 안내 문구 구조화',
              '기능별 QA(버그 리포트/재현) 및 운영 관리 지원',
              '프로젝트 인스타 계정 운영/관리(공지·콘텐츠 업로드/정리)',
            ],
          ),
          const SizedBox(height: 12),

          _MemberProCard(
            icon: Icons.palette_rounded,
            name: '여성구',
            dept: '산업디자인학과 · 26학번',
            headerBadge: const _TinyBadge(
              text: 'DESIGN',
              icon: Icons.brush_rounded,
            ),
            rolePills: const [
              '디자인 총괄',
              '피그마',
              '쇼츠 편집',
              '홍보/마케팅',
            ],
            highlightsTitle: '디자인·홍보·마케팅 기여',
            highlights: const [
              'Figma 기반 UI/UX 및 컴포넌트 디자인 총괄(톤앤매너/가이드 유지)',
              '쇼츠(Shorts)용 편집 및 홍보 콘텐츠 제작 방향 제안',
              '홍보물/마케팅 비주얼 방향 수립 및 대외 커뮤니케이션 지원',
            ],
          ),

          const SizedBox(height: 16),

          // ===== FOOTER MESSAGE =====
          _FooterNote(t: t),

          const SizedBox(height: 14),

          // ===== SMALL DISCLAIMER =====
          Text(
            '※ 팀/역할은 프로젝트 진행에 따라 확장될 수 있습니다.',
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.paejaeNavy.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   HERO (Landing section)
========================= */

class _HeroPortfolio extends StatelessWidget {
  final TextTheme t;
  const _HeroPortfolio({required this.t});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.paejaeBlue.withOpacity(0.94),
                    AppColors.paejaeBlue.withOpacity(0.70),
                    AppColors.paejaeNavy.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          // subtle grain-ish overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  backgroundBlendMode: BlendMode.overlay,
                  border: Border.all(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),

          const Positioned(right: -60, top: -50, child: _HeroBlob(size: 170, alpha: 0.18)),
          const Positioned(left: -70, bottom: -80, child: _HeroBlob(size: 220, alpha: 0.14)),

          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            constraints: const BoxConstraints(minHeight: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroChip(icon: Icons.school_rounded, text: 'PaiChai University'),
                    _HeroChip(icon: Icons.rocket_launch_rounded, text: 'Capstone'),
                    _HeroChip(icon: Icons.verified_rounded, text: 'Student-built “Official App”'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '신박한 26학번',
                  style: t.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '학생이 직접 만드는 “정식 앱” 프로젝트',
                  style: t.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '캠퍼스에 실제로 쓰이는 서비스',
                  style: t.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.90),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: const [
                    Expanded(child: _SoftCTA(text: 'Build • Ship • Improve', icon: Icons.auto_awesome_rounded)),
                    SizedBox(width: 10),
                    Expanded(child: _SoftCTA(text: 'Team Portfolio', icon: Icons.folder_copy_rounded)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBlob extends StatelessWidget {
  final double size;
  final double alpha;
  const _HeroBlob({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(alpha),
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
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.95)),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCTA extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SoftCTA({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(0.95)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   QUICK STATS
========================= */

class _QuickStats extends StatelessWidget {
  final TextTheme t;
  const _QuickStats({required this.t});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              t: t,
              icon: Icons.groups_rounded,
              title: '팀원',
              value: '4',
              sub: 'Core members',
            ),
          ),
          Container(width: 1, height: 54, color: Colors.black.withOpacity(0.06)),
          Expanded(
            child: _StatTile(
              t: t,
              icon: Icons.layers_rounded,
              title: '역할',
              value: 'Dev/Plan/Design/Content',
              sub: 'Full stack team',
              compactValue: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final TextTheme t;
  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final bool compactValue;

  const _StatTile({
    required this.t,
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Icon(icon, color: AppColors.paejaeBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.paejaeNavy.withOpacity(0.70),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: compactValue ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: (compactValue ? t.titleSmall : t.titleMedium)?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: AppColors.paejaeNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.paejaeNavy.withOpacity(0.55),
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
   MEMBER PRO CARD
========================= */

class _MemberProCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String dept;
  final List<String> rolePills;
  final String highlightsTitle;
  final List<String> highlights;
  final Widget? headerBadge;

  const _MemberProCard({
    required this.icon,
    required this.name,
    required this.dept,
    required this.rolePills,
    required this.highlightsTitle,
    required this.highlights,
    this.headerBadge,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.paejaeBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Icon(icon, size: 26, color: AppColors.paejaeBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: AppColors.paejaeNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dept,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.paejaeNavy.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              headerBadge ??
                  const _TinyBadge(text: 'PORTFOLIO', icon: Icons.workspace_premium_rounded),
            ],
          ),

          const SizedBox(height: 12),

          // role pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rolePills.map((p) => _PillTag(text: p)).toList(),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 12),

          // highlights
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 18, color: AppColors.paejaeBlue.withOpacity(0.95)),
              const SizedBox(width: 6),
              Text(
                highlightsTitle,
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.paejaeNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...highlights.where((e) => e.trim().isNotEmpty).map((h) => _BulletLine(text: h)),
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String text;
  const _PillTag({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.paejaeBlue.withOpacity(0.12)),
      ),
      child: Text(
        text,
        style: t.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.paejaeNavy.withOpacity(0.82),
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withOpacity(0.85),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: AppColors.paejaeNavy.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   FOOTER
========================= */

class _FooterNote extends StatelessWidget {
  final TextTheme t;
  const _FooterNote({required this.t});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withOpacity(0.75),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '이 앱은 배재대학교 학생들의 실제 캠퍼스 경험에서 출발했습니다. 다음 이야기는 당신이 이어가 주세요.',
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.45,
                letterSpacing: -0.2,
                color: AppColors.paejaeNavy.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   SMALL BADGE
========================= */

class _TinyBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  const _TinyBadge({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.paejaeBlue),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.paejaeNavy.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }
}