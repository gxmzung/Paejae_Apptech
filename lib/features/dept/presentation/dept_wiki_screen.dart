import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';

import 'dept_data.dart';
import 'dept_detail_screen.dart';
import 'dept_model.dart';


class DeptWikiScreen extends StatefulWidget {
  static const routeName = '/dept';

  const DeptWikiScreen({super.key});

  @override
  State<DeptWikiScreen> createState() => _DeptWikiScreenState();
}

class _DeptWikiScreenState extends State<DeptWikiScreen> {
  final _q = TextEditingController();
  DeptCategory? _filter; // null = 전체

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<DeptInfo> get _filtered {
    final query = _q.text.trim();
    final lower = query.toLowerCase();

    Iterable<DeptInfo> list = deptAll;

    if (_filter != null) {
      list = list.where((d) => d.category == _filter);
    }

    if (query.isNotEmpty) {
      list = list.where((d) {
        final nameHit = d.name.toLowerCase().contains(lower);
        final tagHit = d.tags.any((t) => t.toLowerCase().contains(lower));
        final catHit = d.category.label.toLowerCase().contains(lower);
        return nameHit || tagHit || catHit;
      });
    }

    final out = list.toList();
    out.sort((a, b) => a.name.compareTo(b.name));
    return out;
  }

  void _reset() {
    setState(() {
      _q.clear();
      _filter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.paejaeNavy,
        title:
            const Text('학과 백과', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: '초기화',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          // =========================
          // 검색바
          // =========================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _q,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '학과명/키워드로 검색 (예: 간호, 소프트웨어, 관광)',
                      hintStyle: TextStyle(
                        color: AppColors.paejaeNavy.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w700,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_q.text.isNotEmpty)
                  IconButton(
                    tooltip: '지우기',
                    onPressed: () => setState(() => _q.clear()),
                    icon: const Icon(Icons.close_rounded),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // =========================
          // 카테고리 필터 칩
          // =========================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CatChip(
                  text: '전체',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: 8),
                ...DeptCategory.values.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CatChip(
                      text: c.label,
                      selected: _filter == c,
                      onTap: () => setState(() => _filter = c),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text('학과 (${list.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16)),
              const Spacer(),
              Text(
                _filter?.label ?? '전체',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.paejaeNavy.withValues(alpha: 0.55)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // =========================
          // 리스트
          // =========================
          ...list.map(
            (d) => _DeptTile(
              dept: d,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeptDetailScreen(dept: d)),
              ),
            ),
          ),

          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Text(
                '검색 결과가 없어요.\n다른 키워드로 시도해봐!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.paejaeNavy.withValues(alpha: 0.72),
                  height: 1.35,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* =========================
   Widgets
========================= */

class _CatChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.paejaeBlue.withValues(alpha: 0.16),
      side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
    );
  }
}

class _DeptTile extends StatelessWidget {
  final DeptInfo dept;
  final VoidCallback onTap;

  const _DeptTile({
    required this.dept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            _Mascot(asset: dept.mascotAsset, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dept.name,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    dept.category.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.paejaeNavy.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: dept.tags
                        .take(3)
                        .map((t) => _TagPill(text: t))
                        .toList(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.paejaeNavy.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}

class _Mascot extends StatelessWidget {
  final String asset;
  final double size;

  const _Mascot({
    required this.asset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/brand/paejae_logo.png', fit: BoxFit.contain),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;

  const _TagPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.paejaeBlue.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.paejaeNavy.withValues(alpha: 0.78),
        ),
      ),
    );
  }
}
