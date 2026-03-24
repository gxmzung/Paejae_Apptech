import 'package:flutter/material.dart';

class LostFoundReportScreen extends StatelessWidget {
  const LostFoundReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('분실물 제보')),
      body: const Center(
        child: Text('LostFoundReportScreen (추후 폼 추가)'),
      ),
    );
  }
}