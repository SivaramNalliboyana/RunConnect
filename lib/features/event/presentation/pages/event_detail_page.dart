import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/event/presentation/widgets/location_preview_map.dart';
import 'package:runconnect/features/profile/presentation/widgets/event_participants_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event});

  final Event event;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    final hasCoords = event.lat != null && event.lng != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surfaceVariant,
            foregroundColor: AppColors.onBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.35),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _Banner(imageUrl: event.imageUrl),
                  const _BannerScrim(),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: _HostOverlay(
                      hostId: event.hostId,
                      name: event.hostName,
                      avatarUrl: event.hostAvatarUrl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${_formatDate(event.startsAt)} • ${_formatTime(event.startsAt)}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.meetingPoint,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.straighten_outlined,
                    text:
                        '${_formatKm(event.distanceKm)} km • ${event.paceLevel.label} pace (${event.paceLevel.paceRangeLabel})',
                  ),
                  const SizedBox(height: 16),
                  _GoingPill(
                    current: event.currentParticipants,
                    max: event.maxParticipants,
                    onTap: () => showEventParticipantsSheet(
                      context,
                      eventId: event.id,
                      eventTitle: event.title,
                    ),
                  ),
                  if (hasCoords) ...[
                    const SizedBox(height: 22),
                    Text('Meeting Point', style: AppTextStyles.label),
                    const SizedBox(height: 10),
                    LocationPreviewMap(
                      lat: event.lat!,
                      lng: event.lng!,
                      address: event.meetingPoint,
                    ),
                    const SizedBox(height: 12),
                    _DirectionsButton(lat: event.lat!, lng: event.lng!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKm(double km) =>
      km.truncateToDouble() == km ? km.toStringAsFixed(0) : km.toStringAsFixed(1);
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
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8EBDC), Color(0xFF8FB89A)],
        ),
      ),
      child: Center(
        child: Icon(Icons.directions_run, size: 80, color: Color(0xCC1B3D2F)),
      ),
    );
  }
}

class _BannerScrim extends StatelessWidget {
  const _BannerScrim();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x66000000),
              Color(0x00000000),
              Color(0x88000000),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
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
                width: 40,
                height: 40,
                child: avatarUrl == null || avatarUrl!.isEmpty
                    ? Container(
                        color: AppColors.surfaceVariant,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          size: 20,
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
                            size: 20,
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
                fontSize: 16,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onBackground,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoingPill extends StatelessWidget {
  const _GoingPill({
    required this.current,
    required this.max,
    required this.onTap,
  });

  final int current;
  final int max;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFull = current >= max;
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: isFull ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                isFull ? 'Full' : '$current / $max going',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isFull ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: isFull ? AppColors.error : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionsButton extends StatelessWidget {
  const _DirectionsButton({required this.lat, required this.lng});

  final double lat;
  final double lng;

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _openDirections,
        icon: const Icon(Icons.directions, size: 18),
        label: const Text('Get directions'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
