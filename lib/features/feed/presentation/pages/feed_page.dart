import 'package:flutter/material.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/feed/presentation/widgets/feed_event_card.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  static final _mockEvents = <Event>[
    Event(
      id: '1',
      title: 'Berlin City Sprint',
      distanceKm: 10,
      maxParticipants: 30,
      currentParticipants: 18,
      paceLevel: PaceLevel.intermediate,
      startsAt: DateTime(2024, 10, 12, 7, 30),
      meetingPoint: 'Brandenburg Gate',
      imageUrl: "",
      hostName: 'Lena Becker',
      hostAvatarUrl: null,
    ),
    Event(
      id: '2',
      title: 'Alpine Ridge Run',
      distanceKm: 15,
      maxParticipants: 20,
      currentParticipants: 20,
      paceLevel: PaceLevel.advanced,
      startsAt: DateTime(2024, 11, 5, 6, 0),
      meetingPoint: 'Alpine Trailhead',
      imageUrl: "",
      hostName: 'Marco Rossi',
      hostAvatarUrl: null,
    ),
    Event(
      id: '3',
      title: 'Riverside Social 5K',
      distanceKm: 5,
      maxParticipants: 50,
      currentParticipants: 22,
      paceLevel: PaceLevel.intermediate,
      startsAt: DateTime(2024, 10, 28, 18, 15),
      meetingPoint: 'Riverside Park',
      imageUrl: "",
      hostName: 'Sarah Johnson',
      hostAvatarUrl: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.directions_run,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'RunConnect',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                InkWell(
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: _mockEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return FeedEventCard(
                  event: _mockEvents[index],
                  onJoinPressed: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
