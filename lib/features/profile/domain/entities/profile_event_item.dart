class ProfileEventItem {
  final String id;
  final String title;
  final DateTime startsAt;
  final double distanceKm;
  final String meetingPoint;
  final bool isHosting;

  const ProfileEventItem({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.distanceKm,
    required this.meetingPoint,
    required this.isHosting,
  });
}

class MyEventsBucket {
  final List<ProfileEventItem> upcoming;
  final List<ProfileEventItem> past;

  const MyEventsBucket({required this.upcoming, required this.past});

  const MyEventsBucket.empty() : upcoming = const [], past = const [];
}
