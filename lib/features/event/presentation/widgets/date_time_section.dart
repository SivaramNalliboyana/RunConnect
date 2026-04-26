import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class DateTimeSection extends StatelessWidget {
  const DateTimeSection({super.key});

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
            children: const [
              Expanded(
                flex: 2,
                child: _IconField(
                  icon: Icons.calendar_today_outlined,
                  hint: 'mm/dd/yyyy',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: _IconField(
                  icon: Icons.access_time,
                  hint: '--:-- --',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Meeting Point', style: AppTextStyles.label),
          const SizedBox(height: 8),
          const _IconField(
            icon: Icons.location_on,
            hint: 'Search for a location...',
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          const _MapPreview(),
        ],
      ),
    );
  }
}

class _IconField extends StatelessWidget {
  const _IconField({
    required this.icon,
    required this.hint,
    this.iconColor,
  });

  final IconData icon;
  final String hint;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMuted,
        prefixIcon: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.textMuted,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        filled: true,
        fillColor: AppColors.surface,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
      ),
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      );
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 130,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6FA1B5), Color(0xFF8AB58A)],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 36,
          ),
        ),
      ),
    );
  }
}
