import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);

  Future<MyEventsBucket> getMyEvents(String userId);

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
  Future<MyEventsBucket> getMyEvents(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('events')
            .select('id, title, distance_km, starts_at, meeting_point, host_id')
            .eq('host_id', userId),
        _client
            .from('event_participants')
            .select(
              'event:events!inner('
              'id, title, distance_km, starts_at, meeting_point, host_id)',
            )
            .eq('user_id', userId),
      ]);

      final hostedRows = (results[0] as List).cast<Map<String, dynamic>>();
      final participantRows = (results[1] as List).cast<Map<String, dynamic>>();

      final byId = <String, ProfileEventItem>{};

      for (final row in hostedRows) {
        final item = _mapEvent(row, userId);
        byId[item.id] = item;
      }

      for (final row in participantRows) {
        final eventMap = row['event'] as Map<String, dynamic>?;
        if (eventMap == null) continue;
        final item = _mapEvent(eventMap, userId);
        byId.putIfAbsent(item.id, () => item);
      }

      final now = DateTime.now().toUtc();
      final upcoming = <ProfileEventItem>[];
      final past = <ProfileEventItem>[];
      for (final item in byId.values) {
        if (item.startsAt.toUtc().isBefore(now)) {
          past.add(item);
        } else {
          upcoming.add(item);
        }
      }

      upcoming.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      past.sort((a, b) => b.startsAt.compareTo(a.startsAt));

      return MyEventsBucket(upcoming: upcoming, past: past);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  ProfileEventItem _mapEvent(Map<String, dynamic> row, String userId) {
    return ProfileEventItem(
      id: row['id'] as String,
      title: row['title'] as String,
      startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
      distanceKm: (row['distance_km'] as num).toDouble(),
      meetingPoint: row['meeting_point'] as String,
      isHosting: (row['host_id'] as String?) == userId,
    );
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
