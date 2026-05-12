import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';
import 'package:runconnect/features/board/domain/repositories/board_repository.dart';

class GetLeaderboardUseCase {
  final BoardRepository _repository;
  GetLeaderboardUseCase(this._repository);

  Future<LeaderboardResult> call({
    required String window,
    required String audience,
  }) {
    return _repository.getLeaderboard(window: window, audience: audience);
  }
}
