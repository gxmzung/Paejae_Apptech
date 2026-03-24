import 'package:flutter/material.dart';
import 'package:apptech_flutter/core/widgets/ui.dart';
import '../data/club_model.dart';

class ClubDetailScreen extends StatelessWidget {
  final ClubModel club;

  const ClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          club.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: club.imageAsset.isEmpty
                  ? Container(
                color: AppColors.paejaeBlue.withOpacity(0.08),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 72,
                  color: AppColors.paejaeBlue,
                ),
              )
                  : Image.asset(
                club.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.paejaeBlue.withOpacity(0.08),
                  child: const Icon(
                    Icons.groups_rounded,
                    size: 72,
                    color: AppColors.paejaeBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoBox(
            title: '기본 정보',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('카테고리', club.category),
                _line('위치', club.location),
                _line('연락처', club.contact),
                _line('인스타그램', club.instagram.isEmpty ? '-' : club.instagram),
                _line('모집 여부', club.recruiting ? '모집중' : '모집마감'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoBox(
            title: '소개',
            child: Text(
              club.description,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoBox(
            title: '활동 요일',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: club.meetingDays
                  .map(
                    (e) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paejaeBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.paejaeNavy,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _InfoBox(
            title: '태그',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: club.tags
                  .map(
                    (e) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.paejaeNavy,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoBox({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.paejaeNavy,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}