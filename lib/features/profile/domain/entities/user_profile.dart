class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final int followingCount;
  final int followersCount;
  final double totalKmRun;
  final int eventsJoined;
  final int eventsOrganized;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.followingCount,
    required this.followersCount,
    required this.totalKmRun,
    required this.eventsJoined,
    required this.eventsOrganized,
  });
}
