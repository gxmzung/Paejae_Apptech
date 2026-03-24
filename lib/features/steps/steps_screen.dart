import 'package:flutter/material.dart';
import 'steps_service.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  @override
  void initState() {
    super.initState();
    StepsService.instance.start();
  }

  @override
  void dispose() {
    // 앱 전체에서 계속 쓰면 stop 안 해도 됨.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘 걸음')),
      body: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: StepsService.instance.todaySteps,
          builder: (_, steps, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$steps', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('오늘 걸음 수'),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => StepsService.instance.start(),
                child: const Text('권한/센서 다시 연결'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}