import 'package:runconnect/features/event/domain/entities/event.dart';

class ProfileEventItem {
  final String id;
  final String title;
  final DateTime startsAt;
  final double distanceKm;
  final int maxParticipants;
  final int currentParticipants;
  final PaceLevel paceLevel;
  final String meetingPoint;
  final double? lat;
  final double? lng;
  final String? imageUrl;
  final bool isHosting;

  const ProfileEventItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.distanceKm,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.paceLevel,
    required this.meetingPoint,
    required this.isHosting,
    this.lat,
    this.lng,
    this.imageUrl,
  });
}

class MyEventsBucket {
  final List<ProfileEventItem> upcoming;
  final List<ProfileEventItem> past;

  const MyEventsBucket({required this.upcoming, required this.past});

  const MyEventsBucket.empty() : upcoming = const [], past = const [];
}
