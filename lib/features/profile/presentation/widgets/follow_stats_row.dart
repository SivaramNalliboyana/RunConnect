import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class FollowStatsRow extends StatelessWidget {
  const FollowStatsRow({
    super.key,
    required this.followingCount,
    required this.followersCount,
    this.onFollowingTap,
    this.onFollowersTap,
  });

  final int followingCount;
  final int followersCount;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;

  static String _format(int n) {
    if (n >= 1000) {
      final v = n / 1000;
      return '${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1)}k';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Stat(
          value: _format(followingCount),
          label: 'Following',
          onTap: onFollowingTap,
        ),
        Container(
          width: 1,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          color: Colors.black12,
        ),
        _Stat(
          value: _format(followersCount),
          label: 'Followers',
          onTap: onFollowersTap,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
