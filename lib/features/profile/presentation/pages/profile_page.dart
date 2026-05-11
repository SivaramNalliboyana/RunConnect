import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_state.dart';
import 'package:runconnect/features/profile/presentation/widgets/events_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/profile_header.dart';
import 'package:runconnect/features/profile/presentation/widgets/total_km_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static final _mockUpcomingEvents = <_ProfileEventMock>[
    _ProfileEventMock(
      id: 'u1',
      title: 'Sunrise Beach Run',
      startsAt: DateTime(2026, 5, 14, 6, 30),
      distanceKm: 6.0,
      meetingPoint: 'Marine Drive',
      isHosting: true,
    ),
    _ProfileEventMock(
      id: 'u2',
      title: 'Weekend Trail Long Run',
      startsAt: DateTime(2026, 5, 17, 7, 0),
      distanceKm: 12.0,
      meetingPoint: 'Sanjay Gandhi Park',
    ),
    _ProfileEventMock(
      id: 'u3',
      title: 'Tuesday Tempo',
      startsAt: DateTime(2026, 5, 19, 18, 30),
      distanceKm: 8.0,
      meetingPoint: 'BKC Promenade',
    ),
  ];

  static final _mockPastEvents = <_ProfileEventMock>[
    _ProfileEventMock(
      id: 'p1',
      title: 'City Marathon Prep',
      startsAt: DateTime(2026, 4, 20, 6, 0),
      distanceKm: 15.0,
      meetingPoint: 'Bandra Reclamation',
    ),
    _ProfileEventMock(
      id: 'p2',
      title: 'Evening 5K Social',
      startsAt: DateTime(2026, 4, 12, 18, 30),
      distanceKm: 5.0,
      meetingPoint: 'Powai Lake',
      isHosting: true,
    ),
    _ProfileEventMock(
      id: 'p3',
      title: 'Sunday Hill Repeats',
      startsAt: DateTime(2026, 4, 5, 6, 45),
      distanceKm: 9.0,
      meetingPoint: 'Pali Hill',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc()..add(ProfileRequested()),
      child: _ProfileView(
        upcomingEvents: _mockUpcomingEvents,
        pastEvents: _mockPastEvents,
      ),
    );
  }

  static ProfileBloc _buildBloc() {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id ?? '';
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(client),
    );
    return ProfileBloc(
      getUserProfile: GetUserProfileUseCase(repository),
      userId: userId,
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.upcomingEvents,
    required this.pastEvents,
  });

  final List<_ProfileEventMock> upcomingEvents;
  final List<_ProfileEventMock> pastEvents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            switch (state.status) {
              case ProfileStatus.initial:
              case ProfileStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              case ProfileStatus.failure:
                return _ErrorView(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () =>
                      context.read<ProfileBloc>().add(ProfileRequested()),
                );
              case ProfileStatus.success:
                final profile = state.profile;
                if (profile == null) {
                  return const SizedBox.shrink();
                }
                return _Loaded(
                  profile: profile,
                  upcomingEvents: upcomingEvents,
                  pastEvents: pastEvents,
                );
            }
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.profile,
    required this.upcomingEvents,
    required this.pastEvents,
  });

  final UserProfile profile;
  final List<_ProfileEventMock> upcomingEvents;
  final List<_ProfileEventMock> pastEvents;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                ProfileHeader(
                  displayName: profile.displayName,
                  avatarUrl: profile.avatarUrl,
                ),
                const SizedBox(height: 16),
                FollowStatsRow(
                  followingCount: profile.followingCount,
                  followersCount: profile.followersCount,
                  onFollowingTap: () => context.push('/profile/following'),
                  onFollowersTap: () => context.push('/profile/followers'),
                ),
                const SizedBox(height: 20),
                TotalKmCard(totalKm: profile.totalKmRun),
                const SizedBox(height: 12),
                EventsStatsRow(
                  eventsJoined: profile.eventsJoined,
                  eventsOrganized: profile.eventsOrganized,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: _MyEventsSection(
                    upcoming: upcomingEvents,
                    past: pastEvents,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEventMock {
  const _ProfileEventMock({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.distanceKm,
    required this.meetingPoint,
    this.isHosting = false,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final double distanceKm;
  final String meetingPoint;
  final bool isHosting;
}

class _MyEventsSection extends StatelessWidget {
  const _MyEventsSection({required this.upcoming, required this.past});

  final List<_ProfileEventMock> upcoming;
  final List<_ProfileEventMock> past;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: TabBar(
              labelColor: AppColors.onPrimary,
              unselectedLabelColor: AppColors.textMuted,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              splashFactory: NoSplash.splashFactory,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: TabBarView(
              children: [
                _EventList(events: upcoming, isPast: false),
                _EventList(events: past, isPast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events, required this.isPast});

  final List<_ProfileEventMock> events;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          isPast ? 'No past events yet' : 'No upcoming events',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => SizedBox(
        width: 260,
        child: _ProfileEventCard(event: events[i], isPast: isPast),
      ),
    );
  }
}

class _ProfileEventCard extends StatelessWidget {
  const _ProfileEventCard({required this.event, required this.isPast});

  final _ProfileEventMock event;
  final bool isPast;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) {
    final hour = d.hour == 0 || d.hour == 12 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final suffix = d.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  String _formatDistance(double km) {
    if (km == km.truncateToDouble()) return '${km.toStringAsFixed(0)} km';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(isPast: isPast, isHosting: event.isHosting),
              const Spacer(),
              Text(
                _formatDistance(event.distanceKm),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${_formatDate(event.startsAt)} • ${_formatTime(event.startsAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.meetingPoint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isPast, required this.isHosting});

  final bool isPast;
  final bool isHosting;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color foreground;

    if (isPast) {
      label = 'Completed';
      foreground = AppColors.textMuted;
    } else if (isHosting) {
      label = 'Hosting';
      foreground = AppColors.primary;
    } else {
      label = 'Joined';
      foreground = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
