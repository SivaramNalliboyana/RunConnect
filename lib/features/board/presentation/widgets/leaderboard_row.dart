import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';

class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final highlight = entry.isCurrentUser;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/user/${entry.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.black12,
            ),
          ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              entry.rank?.toString() ?? '—',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: entry.rank == null
                    ? AppColors.textMuted
                    : highlight
                        ? AppColors.primary
                        : AppColors.onBackground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Avatar(url: entry.avatarUrl, isCurrentUser: highlight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                if (entry.rank == null) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Not ranked yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatKm(entry.distanceKm)} km',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.runsCount} ${entry.runsCount == 1 ? 'run' : 'runs'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  String _formatKm(double km) =>
      km.truncateToDouble() == km ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.isCurrentUser});

  final String? url;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceVariant,
          ),
          clipBehavior: Clip.antiAlias,
          child: url == null
              ? const Icon(
                  Icons.directions_run,
                  size: 22,
                  color: AppColors.primary,
                )
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_run,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
        ),
        if (isCurrentUser)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
