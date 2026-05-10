import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);

  Future<List<PastActivity>> getPastActivities(String userId);

  Future<List<ProfileSummary>> getFollowing(String userId);

  Future<List<ProfileSummary>> getFollowers(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;
  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('profiles')
            .select('id, name, avatar_url')
            .eq('id', userId)
            .single(),
        _client
            .from('events')
            .count(CountOption.exact)
            .eq('host_id', userId),
        _client
            .from('event_participants')
            .count(CountOption.exact)
            .eq('user_id', userId),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final eventsOrganized = results[1] as int;
      final eventsJoined = results[2] as int;

      return UserProfile(
        id: profile['id'] as String,
        displayName: (profile['name'] as String?) ?? 'Runner',
        avatarUrl: profile['avatar_url'] as String?,
        followingCount: 0,
        followersCount: 0,
        totalKmRun: 0,
        eventsJoined: eventsJoined,
        eventsOrganized: eventsOrganized,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<PastActivity>> getPastActivities(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileSummary>> getFollowing(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileSummary>> getFollowers(String userId) {
    throw UnimplementedError();
  }
}
