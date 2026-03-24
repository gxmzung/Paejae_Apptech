import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/features/timetable/widget/time_table_widget_sync.dart';

class WidgetSettingsScreen extends StatefulWidget {
  static const routeName = '/widget-settings';

  const WidgetSettingsScreen({super.key});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  static const String _modeKey = 'widget_preview_mode_v1';

  String _selectedMode = 'medium';
  bool _loading = true;

  final List<_WidgetModeItem> _modes = const [
    _WidgetModeItem(
      keyName: 'love',
      title: '연애모드',
      subtitle: '감성 문구 중심 위젯',
      icon: Icons.favorite_rounded,
    ),
    _WidgetModeItem(
      keyName: 'small',
      title: '초소형',
      subtitle: '핵심 정보만 간단히 표시',
      icon: Icons.crop_square_rounded,
    ),
    _WidgetModeItem(
      keyName: 'medium',
      title: '중형',
      subtitle: '시간표/일정 균형형',
      icon: Icons.widgets_rounded,
    ),
    _WidgetModeItem(
      keyName: 'large',
      title: '전체',
      subtitle: '가장 많은 정보 표시',
      icon: Icons.dashboard_customize_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_modeKey) ?? 'medium';

    if (!mounted) return;
    setState(() {
      _selectedMode = saved;
      _loading = false;
    });
  }

  Future<void> _selectMode(String mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_modeKey, mode);

    if (!mounted) return;
    setState(() {
      _selectedMode = mode;
    });

    await TimetableWidgetSync.sync();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('위젯 설정이 저장됐어요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          '잠금화면 위젯 설정',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: const Text(
              '원하는 잠금화면 위젯 스타일을 선택해줘.\n선택 후 바로 동기화돼.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ..._modes.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ModeCard(
                item: e,
                selected: _selectedMode == e.keyName,
                onTap: () => _selectMode(e.keyName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final _WidgetModeItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.paejaeBlue
                  : Colors.black.withValues(alpha: 0.06),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.paejaeBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: AppColors.paejaeBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.paejaeNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.paejaeBlue,
                )
              else
                const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: Colors.black38,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WidgetModeItem {
  final String keyName;
  final String title;
  final String subtitle;
  final IconData icon;

  const _WidgetModeItem({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}