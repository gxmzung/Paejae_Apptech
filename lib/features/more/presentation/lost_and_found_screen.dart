import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apptech_flutter/core/widgets/ui.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final _desc = TextEditingController();
  final _placeDetail = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String _type = '분실'; // 분실 / 습득
  String _building = '본관';

  File? _imageFile;

  List<Map<String, dynamic>> _items = [];

  final List<String> _buildings = const [
    '본관',
    '자유관',
    '체육관',
    '기숙사',
    '도서관',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _desc.dispose();
    _placeDetail.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('lost_and_found_v1');
    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    setState(() {
      _items = decoded.cast<Map<String, dynamic>>();
    });
  }

  Future<void> _saveItem() async {
    if (_desc.text.trim().isEmpty) return;

    final item = {
      'type': _type,
      'building': _building,
      'detail': _placeDetail.text.trim(),
      'desc': _desc.text.trim(),
      'imagePath': _imageFile?.path,
      'time': DateTime.now().toIso8601String(),
    };

    _items.insert(0, item);

    final sp = await SharedPreferences.getInstance();
    await sp.setString('lost_and_found_v1', jsonEncode(_items));

    _desc.clear();
    _placeDetail.clear();
    setState(() {
      _imageFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('등록 완료!')),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title:
            const Text('분실물 신고', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 신고 폼
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('구분', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TypeChip(
                      label: '분실',
                      selected: _type == '분실',
                      onTap: () => setState(() => _type = '분실'),
                    ),
                    const SizedBox(width: 10),
                    _TypeChip(
                      label: '습득',
                      selected: _type == '습득',
                      onTap: () => setState(() => _type = '습득'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('건물', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                DropdownButtonFormField(
                  initialValue: _building,
                  items: _buildings
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _building = v as String),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _placeDetail,
                  decoration: const InputDecoration(
                    labelText: '상세 장소 (예: 3층 강의실 앞)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: '설명 (색상/특징 등)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('사진 첨부'),
                    ),
                    const SizedBox(width: 12),
                    if (_imageFile != null)
                      const Text('첨부됨',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.paejaeBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _saveItem,
                    child: const Text('등록하기',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('최근 등록', style: TextStyle(fontWeight: FontWeight.w900)),

          const SizedBox(height: 10),

          ..._items.map((e) => _ItemCard(data: e)),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ItemCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${data['type']}] ${data['building']}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            data['detail'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            data['desc'],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          if (data['imagePath'] != null) ...[
            const SizedBox(height: 10),
            Image.file(
              File(data['imagePath']),
              height: 120,
              fit: BoxFit.cover,
            ),
          ],
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
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}
