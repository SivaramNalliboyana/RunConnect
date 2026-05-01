enum LeaderboardPeriod { week, month, year }

enum LeaderboardAudience { everyone, friends }

class BoardState {
  const BoardState({
    this.period = LeaderboardPeriod.week,
    this.audience = LeaderboardAudience.everyone,
  });

  final LeaderboardPeriod period;
  final LeaderboardAudience audience;

  BoardState copyWith({
    LeaderboardPeriod? period,
    LeaderboardAudience? audience,
  }) {
    return BoardState(
      period: period ?? this.period,
      audience: audience ?? this.audience,
    );
  }
}
