import 'package:flutter/material.dart';
import 'package:apptech_flutter/features/lost_found/lost_found_report_screen.dart';

class LostAndFoundScreen extends StatelessWidget {
  const LostAndFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분실물')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '분실물 게시판(추후)\n아래 버튼으로 제보 화면 이동',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LostFoundReportScreen(),
                  ),
                );
              },
              child: const Text('분실물 제보하기'),
            ),
          ],
        ),
      ),
    );
  }
}