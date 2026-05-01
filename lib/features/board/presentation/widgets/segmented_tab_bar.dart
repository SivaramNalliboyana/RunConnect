import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';

class SegmentedTabBar<T> extends StatelessWidget {
  const SegmentedTabBar({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.darkSelected = false,
    this.horizontalPadding = 18,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool darkSelected;

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < values.length; i++)
            _Segment(
              label: labels[i],
              selected: values[i] == selected,
              darkSelected: darkSelected,
              horizontalPadding: horizontalPadding,
              onTap: () => onChanged(values[i]),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.darkSelected,
    required this.horizontalPadding,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool darkSelected;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (selected) {
      bg = darkSelected ? AppColors.primary : AppColors.surface;
      fg = darkSelected ? AppColors.onPrimary : AppColors.primary;
    } else {
      bg = Colors.transparent;
      fg = AppColors.textMuted;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected && !darkSelected
              ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
