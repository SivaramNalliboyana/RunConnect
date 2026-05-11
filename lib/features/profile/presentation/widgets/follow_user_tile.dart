import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';

class FollowUserTile extends StatelessWidget {
  const FollowUserTile({
    super.key,
    required this.user,
    required this.onTogglePressed,
    this.onTap,
  });

  final ProfileSummary user;
  final VoidCallback onTogglePressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
          _Avatar(url: user.avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.handle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.handle!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
            const SizedBox(width: 8),
            _FollowButton(
              isFollowing: user.isFollowing,
              onPressed: onTogglePressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? const Icon(Icons.person, size: 28, color: AppColors.textMuted)
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 28, color: AppColors.textMuted),
            ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.onPressed});

  final bool isFollowing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final following = isFollowing;
    return SizedBox(
      height: 34,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: following ? AppColors.surface : AppColors.primary,
          foregroundColor: following ? AppColors.primary : AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: following ? Colors.black12 : AppColors.primary,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(following ? 'Following' : 'Follow'),
      ),
    );
  }
}
