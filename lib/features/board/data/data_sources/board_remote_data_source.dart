import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class BoardRemoteDataSource {
  Future<LeaderboardResult> getLeaderboard({
    required String window,
    required String audience,
  });
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final SupabaseClient _client;
  BoardRemoteDataSourceImpl(this._client);

  static const _topListSize = 10;

  @override
  Future<LeaderboardResult> getLeaderboard({
    required String window,
    required String audience,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in');
    }

    try {
      final rows = await _client.rpc(
        'get_leaderboard',
        params: {
          'p_window': window,
          'p_audience': audience,
          'p_viewer': user.id,
        },
      );

      final list = (rows as List).cast<Map<String, dynamic>>();
      final entries = <LeaderboardEntry>[];
      LeaderboardEntry? viewerInRanked;

      for (final row in list) {
        final id = row['user_id'] as String;
        final entry = LeaderboardEntry(
          id: id,
          rank: row['rank'] as int,
          displayName: (row['display_name'] as String?) ?? 'Runner',
          avatarUrl: row['avatar_url'] as String?,
          distanceKm: (row['distance_km'] as num).toDouble(),
          runsCount: row['runs_count'] as int,
          isCurrentUser: id == user.id,
        );
        entries.add(entry);
        if (entry.isCurrentUser) viewerInRanked = entry;
      }

      final ranked = entries.take(_topListSize).toList();
      final viewerInRankedSlice = ranked.any((e) => e.isCurrentUser);

      LeaderboardEntry? viewerRow;
      if (viewerInRanked != null && !viewerInRankedSlice) {
        viewerRow = viewerInRanked;
      } else if (viewerInRanked == null) {
        final meta = user.userMetadata ?? const <String, dynamic>{};
        viewerRow = LeaderboardEntry(
          id: user.id,
          rank: null,
          displayName: (meta['name'] as String?) ?? 'You',
          avatarUrl: meta['avatar_url'] as String?,
          distanceKm: 0,
          runsCount: 0,
          isCurrentUser: true,
        );
      }

      return LeaderboardResult(ranked: ranked, viewerRow: viewerRow);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
