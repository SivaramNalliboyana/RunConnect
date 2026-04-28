import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/presentation/widgets/events_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_stats_row.dart';
import 'package:runconnect/features/profile/presentation/widgets/past_activity_card.dart';
import 'package:runconnect/features/profile/presentation/widgets/profile_header.dart';
import 'package:runconnect/features/profile/presentation/widgets/total_km_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _mockProfile = UserProfile(
    id: 'mock',
    displayName: 'Alex Johnson',
    avatarUrl: null,
    followingCount: 842,
    followersCount: 1200,
    totalKmRun: 428,
    eventsJoined: 12,
    eventsOrganized: 3,
  );

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
        child: SingleChildScrollView(
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
                      displayName: _mockProfile.displayName,
                      avatarUrl: _mockProfile.avatarUrl,
                    ),
                    const SizedBox(height: 16),
                    FollowStatsRow(
                      followingCount: _mockProfile.followingCount,
                      followersCount: _mockProfile.followersCount,
                      onFollowingTap: () => context.push('/profile/following'),
                      onFollowersTap: () => context.push('/profile/followers'),
                    ),
                    const SizedBox(height: 20),
                    TotalKmCard(totalKm: _mockProfile.totalKmRun),
                    const SizedBox(height: 12),
                    EventsStatsRow(
                      eventsJoined: _mockProfile.eventsJoined,
                      eventsOrganized: _mockProfile.eventsOrganized,
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
                      onTap: () {},
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
                    for (var i = 0; i < _mockActivities.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      PastActivityCard(activity: _mockActivities[i]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
