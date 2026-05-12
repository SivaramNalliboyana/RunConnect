import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({
    super.key,
    this.date,
    this.time,
    this.onPickDate,
    this.onPickTime,
    this.locationChild,
  });

  final DateTime? date;
  final TimeOfDay? time;
  final VoidCallback? onPickDate;
  final VoidCallback? onPickTime;
  final Widget? locationChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date & Time', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _PickerField(
                  icon: Icons.calendar_today_outlined,
                  hint: 'mm/dd/yyyy',
                  value: date == null ? null : _formatDate(date!),
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _PickerField(
                  icon: Icons.access_time,
                  hint: '--:-- --',
                  value: time == null ? null : _formatTime(time!),
                  onTap: onPickTime,
                ),
              ),
            ],
          ),
          if (locationChild != null) ...[
            const SizedBox(height: 16),
            locationChild!,
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.year}';

  static String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')} $period';
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String hint;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? hint,
                style: value == null
                    ? AppTextStyles.bodyMuted
                    : AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

