import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class CampusEventsScreen extends StatefulWidget {
  const CampusEventsScreen({super.key});

  @override
  State<CampusEventsScreen> createState() => _CampusEventsScreenState();
}

class _CampusEventsScreenState extends State<CampusEventsScreen> {
  bool examSeason = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Event('개강 주간', '캠퍼스 동선/혼잡 증가 예상', Icons.school_rounded),
      _Event('중간고사 시즌', '조용한 공간 추천 강화', Icons.assignment_rounded),
      _Event('축제 시즌', '핫스팟/혼잡 체감 지도', Icons.celebration_rounded),
      _Event('기말고사 시즌', '빈 강의실 우선 추천', Icons.menu_book_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title:
            const Text('캠퍼스 시즌', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          _Card(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시험기간 모드',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.paejaeNavy)),
                      const SizedBox(height: 4),
                      Text(
                        '빈 강의실/조용함 추천이 더 강해집니다.',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color:
                                AppColors.paejaeNavy.withValues(alpha: 0.65)),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: examSeason,
                  onChanged: (v) => setState(() => examSeason = v),
                  activeColor: AppColors.paejaeBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((e) => _Card(
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.paejaeBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(e.icon, color: AppColors.paejaeBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.paejaeNavy)),
                          const SizedBox(height: 4),
                          Text(e.desc,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.paejaeNavy
                                      .withValues(alpha: 0.65))),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Event {
  final String title;
  final String desc;
  final IconData icon;
  _Event(this.title, this.desc, this.icon);
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}
