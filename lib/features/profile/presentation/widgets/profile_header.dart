import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.displayName,
    this.avatarUrl,
  });

  final String displayName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            color: AppColors.surfaceVariant,
          ),
          child: ClipOval(
            child: avatarUrl == null
                ? const Icon(
                    Icons.person,
                    size: 64,
                    color: AppColors.textMuted,
                  )
                : Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }
}
