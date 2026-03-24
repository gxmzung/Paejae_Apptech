import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('나섬봇', '질문 → 답변 → “학습 저장(편집)”으로 Q/A를 쌓아 정확도 업'),
      ('시간표', '선호 옵션(몰아/공강/점심) 설정 후 추천'),
      ('분실물', '사진/위치/설명을 올리면 교내에서 공유 가능(추후)'),
      ('기숙사 벌점', '상황 입력으로 벌점 추정 & 누적 관리'),
      ('안전제보', '위치 기반 제보로 안전/불편 사항 공유'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title:
            const Text('앱 사용법', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...items.map((e) => _GuideCard(title: e.$1, desc: e.$2)),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final String desc;
  const _GuideCard({required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}
