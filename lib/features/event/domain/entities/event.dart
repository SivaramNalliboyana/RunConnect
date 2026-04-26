enum PaceLevel { beginner, intermediate, advanced, elite }

class Event {
  final String id;
  final String title;
  final double distanceKm;
  final int maxParticipants;
  final PaceLevel paceLevel;
  final DateTime startsAt;
  final String meetingPoint;
  final String? imageUrl;

  const Event({
    required this.id,
    required this.title,
    required this.distanceKm,
    required this.maxParticipants,
    required this.paceLevel,
    required this.startsAt,
    required this.meetingPoint,
    this.imageUrl,
  });
}
