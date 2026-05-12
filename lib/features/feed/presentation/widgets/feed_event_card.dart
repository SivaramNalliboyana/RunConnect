import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/profile/presentation/widgets/event_participants_sheet.dart';

class FeedEventCard extends StatelessWidget {
  const FeedEventCard({
    super.key,
    required this.event,
    required this.onJoinPressed,
    this.isJoined = false,
    this.isHost = false,
  });

  final Event event;
  final VoidCallback onJoinPressed;
  final bool isJoined;
  final bool isHost;

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
          SizedBox(
            height: 170,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Banner(imageUrl: event.imageUrl),
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      height: 72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x99000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  right: 96,
                  child: _HostOverlay(
                    hostId: event.hostId,
                    name: event.hostName,
                    avatarUrl: event.hostAvatarUrl,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _GoingBadge(
                    isFull: isFull,
                    current: event.currentParticipants,
                    max: event.maxParticipants,
                    onTap: (isJoined || isHost)
                        ? () => showEventParticipantsSheet(
                            context,
                            eventId: event.id,
                            eventTitle: event.title,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
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
                const SizedBox(height: 10),
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
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.meetingPoint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
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
                      isJoined: isJoined,
                      onPressed: (isFull && !isJoined) ? null : onJoinPressed,
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

class _GoingBadge extends StatelessWidget {
  const _GoingBadge({
    required this.isFull,
    required this.current,
    required this.max,
    this.onTap,
  });

  final bool isFull;
  final int current;
  final int max;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 14,
            color: isFull ? AppColors.error : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            isFull ? 'Full' : '$current/$max going',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isFull ? AppColors.error : AppColors.onBackground,
            ),
          ),
          if (tappable) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: isFull ? AppColors.error : AppColors.primary,
            ),
          ],
        ],
      ),
    );

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
        child: content,
      ),
    );
  }
}

class _HostOverlay extends StatelessWidget {
  const _HostOverlay({
    required this.hostId,
    required this.name,
    this.avatarUrl,
  });

  final String hostId;
  final String name;
  final String? avatarUrl;

  static const _shadow = [
    Shadow(color: Color(0xCC000000), blurRadius: 2, offset: Offset(0, 0)),
    Shadow(color: Color(0x99000000), blurRadius: 6, offset: Offset(0, 1)),
    Shadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 2)),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/user/$hostId'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: ClipOval(
              child: SizedBox(
                width: 32,
                height: 32,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? Container(
                        color: AppColors.surfaceVariant,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      )
                    : Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
                shadows: _shadow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.isFull,
    required this.isJoined,
    required this.onPressed,
  });

  final bool isFull;
  final bool isJoined;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = isJoined ? 'Leave' : (isFull ? 'Full' : 'Join');
    final background = isJoined
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.primary;
    final foreground = isJoined ? AppColors.primary : AppColors.onPrimary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: AppColors.neutral.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.onPrimary,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        elevation: 0,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
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
