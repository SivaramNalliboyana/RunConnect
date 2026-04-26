import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';

class PaceLevelSelector extends StatelessWidget {
  const PaceLevelSelector({super.key, this.selected, this.onSelect});

  final PaceLevel? selected;
  final ValueChanged<PaceLevel>? onSelect;

  static const _levels = <_PaceLevelEntry>[
    _PaceLevelEntry(
      PaceLevel.beginner,
      'Beginner',
      '> 7:00 min/km',
      Icons.directions_walk,
    ),
    _PaceLevelEntry(
      PaceLevel.intermediate,
      'Intermediate',
      '5:30-7:00 min/km',
      Icons.bolt,
    ),
    _PaceLevelEntry(
      PaceLevel.advanced,
      'Advanced',
      '4:30-5:30 min/km',
      Icons.rocket_launch_outlined,
    ),
    _PaceLevelEntry(
      PaceLevel.elite,
      'Elite',
      '< 4:30 min/km',
      Icons.emoji_events_outlined,
    ),
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
            Expanded(child: _card(_levels[0])),
            const SizedBox(width: 12),
            Expanded(child: _card(_levels[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _card(_levels[2])),
            const SizedBox(width: 12),
            Expanded(child: _card(_levels[3])),
          ],
        ),
      ],
    );
  }

  Widget _card(_PaceLevelEntry entry) => _PaceCard(
    entry: entry,
    selected: selected == entry.value,
    onTap: onSelect == null ? null : () => onSelect!(entry.value),
  );
}

class _PaceLevelEntry {
  const _PaceLevelEntry(this.value, this.title, this.pace, this.icon);
  final PaceLevel value;
  final String title;
  final String pace;
  final IconData icon;
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final _PaceLevelEntry entry;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
                  entry.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                Icon(entry.icon, size: 18, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 4),
            Text(entry.pace, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
