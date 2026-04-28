import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/presentation/widgets/past_activity_card.dart';

class PastActivitiesPage extends StatelessWidget {
  const PastActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Past Activities',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _mockActivities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              PastActivityCard(activity: _mockActivities[i]),
        ),
      ),
    );
  }
}

final _mockActivities = <PastActivity>[
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
  PastActivity(
    id: '4',
    title: 'Hill Repeats',
    date: DateTime(2025, 9, 28),
    distanceKm: 6.4,
    paceSecondsPerKm: 295,
  ),
  PastActivity(
    id: '5',
    title: 'Easy Recovery',
    date: DateTime(2025, 9, 24),
    distanceKm: 4.0,
    paceSecondsPerKm: 372,
  ),
  PastActivity(
    id: '6',
    title: 'Tempo Run',
    date: DateTime(2025, 9, 20),
    distanceKm: 9.1,
    paceSecondsPerKm: 270,
  ),
  PastActivity(
    id: '7',
    title: 'Sunday Trail',
    date: DateTime(2025, 9, 15),
    distanceKm: 14.2,
    paceSecondsPerKm: 360,
  ),
  PastActivity(
    id: '8',
    title: 'Evening Jog',
    date: DateTime(2025, 9, 10),
    distanceKm: 5.5,
    paceSecondsPerKm: 340,
  ),
];
