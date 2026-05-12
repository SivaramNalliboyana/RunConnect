import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';

enum LeaderboardPeriod { week, month, year }

enum LeaderboardAudience { everyone, friends }

class BoardState {
  const BoardState({
    this.period = LeaderboardPeriod.week,
    this.audience = LeaderboardAudience.everyone,
    this.isLoading = false,
    this.result = LeaderboardResult.empty,
    this.errorMessage,
  });

  final LeaderboardPeriod period;
  final LeaderboardAudience audience;
  final bool isLoading;
  final LeaderboardResult result;
  final String? errorMessage;

  BoardState copyWith({
    LeaderboardPeriod? period,
    LeaderboardAudience? audience,
    bool? isLoading,
    LeaderboardResult? result,
    Object? errorMessage = _unset,
  }) {
    return BoardState(
      period: period ?? this.period,
      audience: audience ?? this.audience,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _unset = Object();
