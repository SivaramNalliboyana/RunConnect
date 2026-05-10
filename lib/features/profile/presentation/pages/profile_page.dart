import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_state.dart';
import 'package:runconnect/features/profile/presentation/widgets/events_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/past_activity_card.dart';
import 'package:runconnect/features/profile/presentation/widgets/profile_header.dart';
import 'package:runconnect/features/profile/presentation/widgets/total_km_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static final _mockActivities = <PastActivity>[
    PastActivity(
      id: '1',
      title: 'Morning City Run',
      date: DateTime(2025, 10, 12),
      distanceKm: 8.2,
      paceSecondsPerKm: 312,
    ),
    PastActivity(
      id: '2',
      title: 'Park Loop',
      date: DateTime(2025, 10, 8),
      distanceKm: 5.0,
      paceSecondsPerKm: 330,
    ),
    PastActivity(
      id: '3',
      title: 'Riverside Long Run',
      date: DateTime(2025, 10, 3),
      distanceKm: 12.5,
      paceSecondsPerKm: 348,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc()..add(ProfileRequested()),
      child: _ProfileView(activities: _mockActivities),
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
  const _ProfileView({required this.activities});

  final List<PastActivity> activities;

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
                return _Loaded(profile: profile, activities: activities);
            }
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.profile, required this.activities});

  final UserProfile profile;
  final List<PastActivity> activities;

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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Past Activities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile/past-activities'),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < activities.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  SizedBox(
                    width: 280,
                    child: PastActivityCard(activity: activities[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
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
