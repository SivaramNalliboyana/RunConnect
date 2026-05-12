import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';

abstract class BoardRepository {
  Future<LeaderboardResult> getLeaderboard({
    required String window,
    required String audience,
  });
}
