import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';

class FeedEventCard extends StatelessWidget {
  const FeedEventCard({
    super.key,
    required this.event,
    required this.onJoinPressed,
  });

  final Event event;
  final VoidCallback onJoinPressed;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  String _formatTime(DateTime d) {
    final hour = d.hour == 0 || d.hour == 12 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final suffix = d.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final isFull = event.isFull;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 170, child: _Banner(imageUrl: event.imageUrl)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(event.startsAt)} • ${_formatTime(event.startsAt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: isFull ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFull
                          ? 'Full'
                          : '${event.currentParticipants}/${event.maxParticipants} going',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isFull ? AppColors.error : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PACE',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 11,
                              letterSpacing: 1.0,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.paceLevel.paceRangeLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _JoinButton(
                      isFull: isFull,
                      onPressed: isFull ? null : onJoinPressed,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.isFull, required this.onPressed});

  final bool isFull;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: AppColors.neutral.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.onPrimary,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(isFull ? 'Full' : 'Join'),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return const _BannerFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _BannerFallback(),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: const [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD8EBDC), Color(0xFF8FB89A)],
            ),
          ),
        ),
        Center(
          child: Icon(Icons.directions_run, size: 64, color: Color(0xCC1B3D2F)),
        ),
      ],
    );
  }
}
