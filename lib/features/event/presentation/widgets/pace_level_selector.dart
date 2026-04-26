import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class PaceLevelSelector extends StatelessWidget {
  const PaceLevelSelector({super.key});

  static const _levels = <_PaceLevel>[
    _PaceLevel('Beginner', '> 7:00 min/km', Icons.directions_walk),
    _PaceLevel('Intermediate', '5:30-7:00 min/km', Icons.bolt),
    _PaceLevel('Advanced', '4:30-5:30 min/km', Icons.rocket_launch_outlined),
    _PaceLevel('Elite', '< 4:30 min/km', Icons.emoji_events_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT PACE LEVEL',
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _PaceCard(level: _levels[0], selected: false)),
            const SizedBox(width: 12),
            Expanded(child: _PaceCard(level: _levels[1], selected: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _PaceCard(level: _levels[2], selected: false)),
            const SizedBox(width: 12),
            Expanded(child: _PaceCard(level: _levels[3], selected: false)),
          ],
        ),
      ],
    );
  }
}

class _PaceLevel {
  const _PaceLevel(this.title, this.pace, this.icon);
  final String title;
  final String pace;
  final IconData icon;
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({required this.level, required this.selected});

  final _PaceLevel level;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD8EBDC) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black12,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              Icon(level.icon, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 4),
          Text(level.pace, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
