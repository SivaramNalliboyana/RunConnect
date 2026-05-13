import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/data/data_sources/event_remote_data_source.dart';
import 'package:runconnect/features/event/data/repositories/event_repository_impl.dart';
import 'package:runconnect/features/event/domain/use_cases/delete_event_use_case.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_my_events_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/is_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_state.dart';
import 'package:runconnect/features/profile/presentation/widgets/events_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/event_participants_sheet.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/profile_header.dart';
import 'package:runconnect/features/profile/presentation/widgets/total_km_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id ?? '';
    final targetUserId = userId ?? currentUserId;
    final isCurrentUser =
        targetUserId.isNotEmpty && targetUserId == currentUserId;

    return BlocProvider(
      create: (_) =>
          _buildBloc(targetUserId, currentUserId, isCurrentUser)
            ..add(ProfileRequested()),
      child: _ProfileView(isCurrentUser: isCurrentUser),
    );
  }

  static ProfileBloc _buildBloc(
    String userId,
    String currentUserId,
    bool isCurrentUser,
  ) {
    final client = Supabase.instance.client;
    final profileRepository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(client),
    );
    final eventRepository = EventRepositoryImpl(
      EventRemoteDataSourceImpl(client),
    );
    return ProfileBloc(
      getUserProfile: GetUserProfileUseCase(profileRepository),
      getMyEvents: GetMyEventsUseCase(profileRepository),
      isFollowing: IsFollowingUseCase(profileRepository),
      followUser: FollowUserUseCase(profileRepository),
      unfollowUser: UnfollowUserUseCase(profileRepository),
      deleteEvent: DeleteEventUseCase(eventRepository),
      userId: userId,
      currentUserId: currentUserId,
      isCurrentUser: isCurrentUser,
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.isCurrentUser});

  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          isCurrentUser ? 'Profile' : 'Runner',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.primary),
                  onPressed: () {},
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (prev, curr) =>
              prev.actionErrorMessage != curr.actionErrorMessage &&
              curr.actionErrorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionErrorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          },
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
                  myEvents: state.myEvents,
                  isCurrentUser: state.isCurrentUserProfile,
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
    required this.myEvents,
    required this.isCurrentUser,
  });

  final UserProfile profile;
  final MyEventsBucket myEvents;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<ProfileBloc>().add(ProfileRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    onFollowingTap: () =>
                        context.push('/user/${profile.id}/following'),
                    onFollowersTap: () =>
                        context.push('/user/${profile.id}/followers'),
                  ),
                  if (!isCurrentUser) ...[
                    const SizedBox(height: 16),
                    const _FollowButton(),
                  ],
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
                      upcoming: myEvents.upcoming,
                      past: myEvents.past,
                      isCurrentUser: isCurrentUser,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyEventsSection extends StatelessWidget {
  const _MyEventsSection({
    required this.upcoming,
    required this.past,
    required this.isCurrentUser,
  });

  final List<ProfileEventItem> upcoming;
  final List<ProfileEventItem> past;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCurrentUser ? 'My Events' : 'Events',
            style: const TextStyle(
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
            height: 175,
            child: TabBarView(
              children: [
                _EventList(
                  events: upcoming,
                  isPast: false,
                  showActions: isCurrentUser,
                ),
                _EventList(
                  events: past,
                  isPast: true,
                  showActions: isCurrentUser,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({
    required this.events,
    required this.isPast,
    required this.showActions,
  });

  final List<ProfileEventItem> events;
  final bool isPast;
  final bool showActions;

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
        child: _ProfileEventCard(
          event: events[i],
          isPast: isPast,
          showActions: showActions,
        ),
      ),
    );
  }
}

class _ProfileEventCard extends StatelessWidget {
  const _ProfileEventCard({
    required this.event,
    required this.isPast,
    required this.showActions,
  });

  final ProfileEventItem event;
  final bool isPast;
  final bool showActions;

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
              if (showActions && !isPast && event.isHosting) ...[
                const SizedBox(width: 4),
                _EventActionsMenu(event: event),
              ],
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
          const SizedBox(height: 4),
          InkWell(
            onTap: () => showEventParticipantsSheet(
              context,
              eventId: event.id,
              eventTitle: event.title,
            ),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPast
                        ? '${event.currentParticipants} attended'
                        : '${event.currentParticipants}/${event.maxParticipants} going',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
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

class _FollowButton extends StatelessWidget {
  const _FollowButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (prev, curr) =>
          prev.isFollowing != curr.isFollowing ||
          prev.isFollowMutating != curr.isFollowMutating,
      builder: (context, state) {
        final isFollowing = state.isFollowing;
        final isMutating = state.isFollowMutating;

        final background = isFollowing
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.primary;
        final foreground = isFollowing
            ? AppColors.primary
            : AppColors.onPrimary;

        return Center(
          child: SizedBox(
            width: 220,
            height: 42,
            child: ElevatedButton(
              onPressed: isMutating
                  ? null
                  : () => context.read<ProfileBloc>().add(
                      FollowToggleRequested(),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
                elevation: 0,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: isMutating
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(foreground),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFollowing) ...[
                          const Icon(Icons.check_rounded, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Text(isFollowing ? 'Following' : 'Follow'),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

enum _EventAction { edit, delete }

class _EventActionsMenu extends StatelessWidget {
  const _EventActionsMenu({required this.event});

  final ProfileEventItem event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<_EventAction>(
        tooltip: 'Event actions',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (action) => _handle(context, action),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _EventAction.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: _EventAction.delete,
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                SizedBox(width: 10),
                Text('Delete', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(BuildContext context, _EventAction action) async {
    final bloc = context.read<ProfileBloc>();
    switch (action) {
      case _EventAction.edit:
        final saved = await context.push<bool>('/edit-event', extra: event);
        if (saved == true) {
          bloc.add(ProfileRequested());
        }
      case _EventAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete event?'),
            content: Text(
              '“${event.title}” will be removed for everyone who joined.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          bloc.add(MyEventDeleteRequested(event.id));
        }
    }
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
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
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
