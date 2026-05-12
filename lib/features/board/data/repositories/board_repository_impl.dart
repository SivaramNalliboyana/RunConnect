import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/board/data/data_sources/board_remote_data_source.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';
import 'package:runconnect/features/board/domain/repositories/board_repository.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource _dataSource;
  BoardRepositoryImpl(this._dataSource);

  @override
  Future<LeaderboardResult> getLeaderboard({
    required String window,
    required String audience,
  }) async {
    try {
      return await _dataSource.getLeaderboard(
        window: window,
        audience: audience,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
