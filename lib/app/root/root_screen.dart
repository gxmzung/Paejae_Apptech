import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

import 'package:apptech_flutter/features/home/presentation/home_screen.dart';
import 'package:apptech_flutter/features/timetable/presentation/timetable_screen.dart';
import 'package:apptech_flutter/features/points/presentation/points_history_screen.dart';
import 'package:apptech_flutter/features/clubs/presentation/club_all_screen.dart';
import 'package:apptech_flutter/features/more/presentation/more_screen.dart';

class RootScreen extends StatefulWidget {
  static const routeName = '/root';
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    const HomeScreen(),
    const TimeTableScreen(),
    const PointsHistoryScreen(),
    const ClubAllScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.paejaeBlue.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_rounded),
            label: '시간표',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_rounded),
            label: '포인트',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            label: '동아리',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            label: '더보기',
          ),
        ],
      ),
    );
  }
}