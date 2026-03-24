import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

class TodaySummaryScreen extends StatelessWidget {
  const TodaySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // v1: 하드코딩/데모 → 나중에 “학생 제보 + 관리자 큐레이션”으로 확장
    final lines = const [
      '1) 첨단과학관(C) 1층 공사 소음 체감 높음',
      '2) 점심 시간 시민버거 대기 길어짐(12:10~)',
      '3) 오늘 밤 기온 내려감 → 외투 추천',
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('배재 오늘 한 줄 요약',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('오늘 중요한 것 3줄',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.paejaeNavy)),
                const SizedBox(height: 10),
                ...lines.map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(t,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, height: 1.25)),
                    )),
                const SizedBox(height: 12),
                Text(
                  '※ v1은 데모(학교 DB/결제/학생 신상 없음). 체감 정보는 익명 제보 기반으로 고도화 예정.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
