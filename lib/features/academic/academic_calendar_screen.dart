import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import 'package:apptech_flutter/data/repos/pcu_web_repo.dart';

class AcademicCalendarScreen extends StatefulWidget {
  static const routeName = '/academic_calendar';
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final _repo = PcuWebRepo();

  bool _loading = true;
  String _err = '';
  PcuAcademicCalendarResult? _result;

  @override
  void initState() {
    super.initState();
    _load(force: false);
  }

  Future<void> _load({required bool force}) async {
    setState(() {
      _loading = true;
      _err = '';
    });

    try {
      final r = await _repo.loadAcademicCalendar(forceRefresh: force);
      if (!mounted) return;
      setState(() {
        _result = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('학사일정', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: () => _load(force: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_err.isNotEmpty)
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('불러오기 실패\n$_err',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
        ),
      )
          : _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = _result;

    if (r == null || r.events.isEmpty) {
      return Center(
        child: Text('학사일정 데이터가 비어있어요.',
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('기준년도: ${r.baseYear}',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                r.note == null ? '소스: ${r.sourceUrl}' : '주의: ${r.note}\n소스: ${r.sourceUrl}',
                style: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...r.events.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.94),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(e.dateText,
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.70),
                    )),
              ],
            ),
          );
        }),
      ],
    );
  }
}