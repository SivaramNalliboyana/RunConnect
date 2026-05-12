class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.rank,
    required this.displayName,
    required this.distanceKm,
    required this.runsCount,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  final String id;
  final int? rank;
  final String displayName;
  final double distanceKm;
  final int runsCount;
  final String? avatarUrl;
  final bool isCurrentUser;
}

class LeaderboardResult {
  const LeaderboardResult({
    required this.ranked,
    this.viewerRow,
  });

  final List<LeaderboardEntry> ranked;
  final LeaderboardEntry? viewerRow;

  bool get viewerInTopList =>
      viewerRow != null && ranked.any((e) => e.isCurrentUser);

  static const empty = LeaderboardResult(ranked: []);
}
