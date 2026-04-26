import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final TextEditingController? controller;
  final String? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            suffixText: suffix,
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(focused: true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: focused ? AppColors.primary : Colors.black12,
          width: focused ? 1.4 : 1,
        ),
      );
}
