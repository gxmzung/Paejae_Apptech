import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/core/widgets/premium_ui.dart';

class DevNotesScreen extends StatelessWidget {
  const DevNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navy = AppColors.paejaeNavy;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('앱 사용 튜토리얼', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          // ✅ 히어로 카드(프리미엄)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.paejaeBlue,
                  AppColors.paejaeBlue.withValues(alpha: 0.78),
                  AppColors.paejaeNavy.withValues(alpha: 0.92),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumPill(icon: Icons.verified_rounded, text: '배재대 학생용 실사용 프로토타입'),
                const SizedBox(height: 10),
                Text(
                  '걸을수록 쌓이는 포인트,\n캠퍼스 생활을 한 화면에.',
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '이 앱은 “학교 생활에서 진짜 자주 쓰는 기능”을 빠르게 꺼내 쓰도록 설계했어요.\n'
                      '포인트(동기부여) → 교환(보상) → 커뮤니티(연결) → 지도/안전(실행) 흐름으로 돌아갑니다.',
                  style: t.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumSectionHeader(
                  title: '핵심 사용 흐름 (30초)',
                  subtitle: '처음 설치하면 이것만 따라오면 바로 익숙해져요.',
                ),
                const SizedBox(height: 12),
                _step(
                  no: '1',
                  title: '홈에서 “오늘 포인트” 확인',
                  body: '걷기/활동 기반 포인트가 쌓이고, 스트릭/미션처럼 “오늘 할 일”이 보이게 구성돼요.',
                ),
                _step(
                  no: '2',
                  title: '포인트 내역에서 흐름 체크',
                  body: '내가 언제, 어떤 행동으로 포인트를 얻었는지 기록을 확인해요. (습관화)',
                ),
                _step(
                  no: '3',
                  title: '교환/이야기/소통으로 연결',
                  body: '포인트를 교환하거나, 게시판/동아리에서 필요한 정보를 얻고 사람을 만나요.',
                ),
                _step(
                  no: '4',
                  title: '교내지도/안전제보로 “실행”',
                  body: '길찾기/시설/흡연구역/강의실 등 캠퍼스에서 바로 필요한 액션을 수행해요.',
                ),
              ],
            ),
          ),

          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumSectionHeader(
                  title: '기능 안내',
                  subtitle: '더보기 기준으로, 실제 쓰임새를 한 줄로 정리했어요.',
                ),
                const SizedBox(height: 12),

                _feature(
                  icon: Icons.directions_walk_rounded,
                  title: '포인트(본질)',
                  body: '걸으면서 포인트를 얻고, 기록이 쌓이면서 “캠퍼스 생활 루틴”을 만드는 기능이에요.',
                ),
                _feature(
                  icon: Icons.query_stats_rounded,
                  title: '통계/혼잡예측',
                  body: '내 패턴과 캠퍼스 상황을 한 번에 보여줘요. (어디가 붐비는지/언제 움직일지)',
                ),
                _feature(
                  icon: Icons.receipt_long_rounded,
                  title: '교환/포인트 내역',
                  body: '포인트의 “가치”를 만들고, 얻고-쓰는 흐름을 명확하게 보여줘요.',
                ),
                _feature(
                  icon: Icons.forum_rounded,
                  title: '이야기/소통(게시판·동아리)',
                  body: '필요한 정보가 빨리 모이고, 학생들끼리 안전하게 연결되는 구조예요.',
                ),
                _feature(
                  icon: Icons.map_rounded,
                  title: '교내지도',
                  body: '건물/시설/강의실/흡연구역 등 캠퍼스에서 필요한 걸 빠르게 찾도록 돕는 화면이에요.',
                ),
                _feature(
                  icon: Icons.layers_rounded,
                  title: '캠퍼스맵(공식 안내 페이지)',
                  body: '학교 공식 캠퍼스 안내 페이지를 바로 열어 “정확한 자료”를 빠르게 확인해요.',
                ),
                _feature(
                  icon: Icons.report_rounded,
                  title: '안전제보',
                  body: '위험/불편/고장 등을 빠르게 공유해 안전한 캠퍼스를 만드는 기능이에요.',
                ),
                _feature(
                  icon: Icons.calculate_rounded,
                  title: '학점·기숙사 계산기',
                  body: '학생이 자주 쓰는 도구를 앱 안에서 끝내도록 넣었어요. (생활 편의)',
                ),
              ],
            ),
          ),

          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumSectionHeader(
                  title: '운영 가이드',
                  subtitle: '실명 커뮤니티/안전/신뢰를 위한 기준',
                ),
                const SizedBox(height: 10),
                _bullet('실명 커뮤니티를 기본으로, 비방·개인정보·홍보는 강하게 제한합니다.'),
                _bullet('신고/차단/필터로 사용자 보호를 우선합니다.'),
                _bullet('학교 공식 정보(캠퍼스맵/학사일정 등)는 링크/고정 데이터로 정확성을 담보합니다.'),
              ],
            ),
          ),

          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumSectionHeader(
                  title: 'FAQ',
                  subtitle: '발표/데모할 때 질문 많이 나오는 것들',
                ),
                const SizedBox(height: 10),
                _qa(
                  q: '이 앱의 한 줄 요약은?',
                  a: '“걸을수록 가치가 쌓이고, 캠퍼스 생활이 편해지는 학생용 슈퍼앱”이에요.',
                ),
                _qa(
                  q: '왜 포인트가 핵심이야?',
                  a: '행동(걷기/활동)을 습관으로 만들고, 교환/커뮤니티로 연결되며 ‘매일 켜게 되는 이유’를 만들기 때문이에요.',
                ),
                _qa(
                  q: '정식 서비스로 가려면?',
                  a: '인증/약관/데이터 정책 + 학교 DB 연동 + 운영툴(신고/제보 처리)만 붙으면 “채택 가능한 구조”예요.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Text(
            '© AppTech Prototype · Paichai University',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: navy.withValues(alpha: 0.45),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _step({required String no, required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.18)),
            ),
            child: Text(
              no,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.paejaeBlue),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _feature({required IconData icon, required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: AppColors.paejaeBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: AppColors.paejaeBlue.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.35,
                color: AppColors.paejaeNavy.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qa({required String q, required String a}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q. $q', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            'A. $a',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: AppColors.paejaeNavy.withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}
