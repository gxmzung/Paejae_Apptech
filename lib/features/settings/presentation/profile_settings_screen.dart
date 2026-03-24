// lib/features/settings/presentation/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/core/constants/prefs_keys.dart';
import 'package:apptech_flutter/features/settings/presentation/activity_advanced_settings_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  static const routeName = '/settings/profile';
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _weightCtrl = TextEditingController();

  bool _loading = true;
  double _weight = 65.0; // default (합리적 기본값)
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final w = sp.getDouble(PrefKeys.userWeightKg) ?? 65.0;

    _weight = w.clamp(30.0, 200.0);
    _weightCtrl.text = _weight.toStringAsFixed(1);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  double? _parseWeight(String s) {
    final t = s.trim().replaceAll(',', '.');
    final v = double.tryParse(t);
    if (v == null) return null;
    if (v < 30 || v > 200) return null;
    return v;
  }

  Future<void> _save() async {
    final parsed = _parseWeight(_weightCtrl.text);
    if (parsed == null) {
      setState(() => _error = '체중은 30~200kg 범위로 입력해줘!');
      return;
    }

    final sp = await SharedPreferences.getInstance();
    await sp.setDouble(PrefKeys.userWeightKg, parsed);

    if (!mounted) return;
    setState(() {
      _error = '';
      _weight = parsed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('체중이 저장됐어 ✅')),
    );
  }

  Future<void> _reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(PrefKeys.userWeightKg);

    _weight = 65.0;
    _weightCtrl.text = _weight.toStringAsFixed(1);

    if (!mounted) return;
    setState(() => _error = '');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('체중을 기본값으로 초기화했어')),
    );
  }

  void _openAdvanced() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActivityAdvancedSettingsScreen()),
    );
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
        title: const Text('활동 설정', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        children: [
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.paejaeBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.paejaeBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '체중을 입력하면 칼로리 추정이 훨씬 현실적으로 바뀌어.\n'
                        '정확한 건강 데이터가 아니라 “활동 추정치”로만 사용돼!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.75),
                    ),
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
                const Text('체중', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '칼로리 계산에 사용돼요',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'kg',
                          hintText: '예) 65.0',
                          errorText: _error.isEmpty ? null : _error,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (v) {
                          final p = _parseWeight(v);
                          if (p != null) {
                            setState(() {
                              _weight = p;
                              _error = '';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_weight.toStringAsFixed(1)}kg',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Slider(
                  value: _weight.clamp(30.0, 120.0),
                  min: 30,
                  max: 120,
                  divisions: 180, // 0.5 단위 느낌
                  onChanged: (v) {
                    setState(() {
                      _weight = (v * 2).roundToDouble() / 2.0;
                      _weightCtrl.text = _weight.toStringAsFixed(1);
                      _error = '';
                    });
                  },
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('초기화', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('저장', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.paejaeBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _Card(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune_rounded, color: AppColors.paejaeNavy),
              ),
              title: const Text('고급 설정', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(
                '목표 걸음 수 · 보폭 · 계수 조절',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.55),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _openAdvanced,
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
