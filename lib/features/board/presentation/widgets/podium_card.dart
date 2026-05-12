import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';

class PodiumCard extends StatelessWidget {
  const PodiumCard({
    super.key,
    required this.first,
    required this.second,
    required this.third,
  });

  final LeaderboardEntry? first;
  final LeaderboardEntry? second;
  final LeaderboardEntry? third;

  static const _gold = Color(0xFFE2B33B);
  static const _silver = Color(0xFFC9CDD2);
  static const _bronze = Color(0xFFE08A5A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 4,
            right: 24,
            child: Icon(
              Icons.emoji_events,
              size: 110,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _PodiumSlot(
                      entry: second,
                      rank: 2,
                      ringColor: _silver,
                      ringSize: 78,
                      badgeColor: _silver,
                      isWinner: false,
                    ),
                  ),
                  Expanded(
                    child: _PodiumSlot(
                      entry: first,
                      rank: 1,
                      ringColor: _gold,
                      ringSize: 96,
                      badgeColor: _gold,
                      isWinner: true,
                    ),
                  ),
                  Expanded(
                    child: _PodiumSlot(
                      entry: third,
                      rank: 3,
                      ringColor: _bronze,
                      ringSize: 78,
                      badgeColor: _bronze,
                      isWinner: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _Podium(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.rank,
    required this.ringColor,
    required this.ringSize,
    required this.badgeColor,
    required this.isWinner,
  });

  final LeaderboardEntry? entry;
  final int rank;
  final Color ringColor;
  final double ringSize;
  final Color badgeColor;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final empty = entry == null;
    return InkWell(
      onTap: empty ? null : () => context.push('/user/${entry!.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Column(
      children: [
        SizedBox(
          height: ringSize + 10,
          width: ringSize + 10,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: empty
                        ? ringColor.withValues(alpha: 0.35)
                        : ringColor,
                    width: 4,
                  ),
                  color: AppColors.surfaceVariant,
                ),
                clipBehavior: Clip.antiAlias,
                child: empty
                    ? Icon(
                        Icons.help_outline,
                        size: ringSize * 0.45,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      )
                    : entry!.avatarUrl == null
                        ? Icon(
                            Icons.directions_run,
                            size: ringSize * 0.55,
                            color: AppColors.primary,
                          )
                        : Image.network(
                            entry!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.directions_run,
                              size: ringSize * 0.55,
                              color: AppColors.primary,
                            ),
                          ),
              ),
              Positioned(
                top: -4,
                child: _RankBadge(
                  rank: rank,
                  color: empty ? badgeColor.withValues(alpha: 0.5) : badgeColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          empty ? 'TBD' : entry!.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isWinner ? 15 : 13,
            fontWeight: FontWeight.w700,
            color: empty ? AppColors.textMuted : AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          empty ? '—' : '${_formatKm(entry!.distanceKm)} km',
          style: TextStyle(
            fontSize: isWinner ? 16 : 13,
            fontWeight: FontWeight.w600,
            color: empty
                ? AppColors.textMuted
                : AppColors.primary,
          ),
        ),
      ],
      ),
    );
  }

  String _formatKm(double km) =>
      km.truncateToDouble() == km ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.color});

  final int rank;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium();

  static const _sideBlock = Color(0xFFB7BEC4);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _Block(height: 60, color: _sideBlock)),
          const SizedBox(width: 8),
          Expanded(child: _Block(height: 92, color: AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _Block(height: 44, color: _sideBlock)),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}
