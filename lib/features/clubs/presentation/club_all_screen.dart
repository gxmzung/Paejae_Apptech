import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import '../data/club_model.dart';
import '../data/club_repo.dart';
import 'club_detail_screen.dart';

class ClubAllScreen extends StatefulWidget {
  static const routeName = '/clubs/all';

  const ClubAllScreen({super.key});

  @override
  State<ClubAllScreen> createState() => _ClubAllScreenState();
}

class _ClubAllScreenState extends State<ClubAllScreen> {
  final ClubRepo _repo = ClubRepo();
  final TextEditingController _searchController = TextEditingController();

  List<ClubModel> _all = [];
  List<ClubModel> _filtered = [];

  bool _loading = true;
  String _error = '';

  String _selectedCategory = '전체';
  bool _onlyRecruiting = false;

  final List<String> _categories = const [
    '전체',
    '전공',
    '체육',
    '문화예술',
    '봉사',
    '종교',
    '학술',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final clubs = await _repo.loadClubs();
      if (!mounted) return;

      setState(() {
        _all = clubs;
        _filtered = clubs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();

    final result = _all.where((club) {
      final categoryMatch =
          _selectedCategory == '전체' || club.category == _selectedCategory;

      final recruitingMatch = !_onlyRecruiting || club.recruiting;

      final searchMatch = q.isEmpty ||
          club.name.toLowerCase().contains(q) ||
          club.summary.toLowerCase().contains(q) ||
          club.tags.any((tag) => tag.toLowerCase().contains(q));

      return categoryMatch && recruitingMatch && searchMatch;
    }).toList();

    setState(() {
      _filtered = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          '전체 동아리',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text('불러오기 실패: $_error'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '동아리 검색',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _selectedCategory = v);
                      _applyFilter();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('모집중'),
                  selected: _onlyRecruiting,
                  onSelected: (v) {
                    setState(() => _onlyRecruiting = v);
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final club = _filtered[index];
                return _ClubListCard(club: club);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubListCard extends StatelessWidget {
  final ClubModel club;

  const _ClubListCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClubDetailScreen(club: club),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.paejaeBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: club.imageAsset.isEmpty
                  ? const Icon(Icons.groups_rounded, color: AppColors.paejaeBlue)
                  : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  club.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.groups_rounded,
                    color: AppColors.paejaeBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          club.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.paejaeNavy,
                          ),
                        ),
                      ),
                      if (club.recruiting)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '모집중',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.62),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Tag(text: club.category),
                      ...club.tags.take(2).map((e) => _Tag(text: e)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.paejaeBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.paejaeNavy,
        ),
      ),
    );
  }
}