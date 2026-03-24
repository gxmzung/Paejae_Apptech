import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/core/constants/prefs_keys.dart';

class ActivityAdvancedSettingsScreen extends StatefulWidget {
  const ActivityAdvancedSettingsScreen({super.key});
  static const routeName = '/settings/activity-advanced';

  @override
  State<ActivityAdvancedSettingsScreen> createState() =>
      _ActivityAdvancedSettingsScreenState();
}

class _ActivityAdvancedSettingsScreenState
    extends State<ActivityAdvancedSettingsScreen> {
  final _strideCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  final _kcalCtrl = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _strideCtrl.dispose();
    _goalCtrl.dispose();
    _kcalCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();

    final stride = (sp.getDouble(PrefKeys.strideMeters) ?? 0.75).clamp(0.3, 2.0);
    final goal = (sp.getInt(PrefKeys.goalSteps) ?? 6400).clamp(1000, 50000);
    final kcal = (sp.getDouble(PrefKeys.kcalPerStep) ?? 0.045).clamp(0.01, 0.2);

    _strideCtrl.text = stride.toStringAsFixed(2);
    _goalCtrl.text = goal.toString();
    _kcalCtrl.text = kcal.toStringAsFixed(3);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  double _parseDouble(String s, double fallback) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? fallback;

  int _parseInt(String s, int fallback) =>
      int.tryParse(s.trim().replaceAll(',', '')) ?? fallback;

  Future<void> _save() async {
    final stride = _parseDouble(_strideCtrl.text, 0.75).clamp(0.3, 2.0);
    final goal = _parseInt(_goalCtrl.text, 6400).clamp(1000, 50000);
    final kcal = _parseDouble(_kcalCtrl.text, 0.045).clamp(0.01, 0.2);

    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(PrefKeys.strideMeters, stride);
    await sp.setInt(PrefKeys.goalSteps, goal);
    await sp.setDouble(PrefKeys.kcalPerStep, kcal);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('고급 설정 저장 완료 ✅')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title: const Text('활동 고급 설정',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child:
            const Text('저장', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('보폭(거리 계산)',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _Field(
                  controller: _strideCtrl,
                  hintText: '예) 0.75',
                  suffix: 'm',
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                Text(
                  '기본값 0.75m (평균 보폭)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('목표(통계 목표선)',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _Field(
                  controller: _goalCtrl,
                  hintText: '예) 6400',
                  suffix: '걸음',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Text(
                  '주간 통계에서 목표선으로 표시돼요',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('칼로리 계수(평균 추정)',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _Field(
                  controller: _kcalCtrl,
                  hintText: '예) 0.045',
                  suffix: 'kcal/step',
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                Text(
                  '체중 미입력 시 평균 추정치에 사용돼요',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.paejaeBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('저장',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String suffix;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.hintText,
    required this.suffix,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.paejaeNavy.withValues(alpha: 0.45),
        ),
        suffixText: suffix,
        suffixStyle: const TextStyle(fontWeight: FontWeight.w900),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
          BorderSide(color: AppColors.paejaeBlue.withValues(alpha: 0.55)),
        ),
      ),
    );
  }
}
