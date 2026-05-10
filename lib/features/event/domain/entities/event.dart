enum PaceLevel { beginner, intermediate, advanced, elite }

extension PaceLevelDisplay on PaceLevel {
  String get label {
    switch (this) {
      case PaceLevel.beginner:
        return 'Beginner';
      case PaceLevel.intermediate:
        return 'Intermediate';
      case PaceLevel.advanced:
        return 'Advanced';
      case PaceLevel.elite:
        return 'Elite';
    }
  }

  String get paceRangeLabel {
    switch (this) {
      case PaceLevel.beginner:
        return '> 7:00/km';
      case PaceLevel.intermediate:
        return '5:30-7:00/km';
      case PaceLevel.advanced:
        return '4:30-5:30/km';
      case PaceLevel.elite:
        return '< 4:30/km';
    }
  }
}

class Event {
  final String id;
  final String title;
  final double distanceKm;
  final int maxParticipants;
  final int currentParticipants;
  final PaceLevel paceLevel;
  final DateTime startsAt;
  final String meetingPoint;
  final String? imageUrl;
  final String hostName;
  final String? hostAvatarUrl;

  const Event({
    required this.id,
    required this.title,
    required this.distanceKm,
    required this.maxParticipants,
    required this.paceLevel,
    required this.startsAt,
    required this.meetingPoint,
    required this.hostName,
    this.currentParticipants = 0,
    this.imageUrl,
    this.hostAvatarUrl,
  });

  bool get isFull => currentParticipants >= maxParticipants;
}
