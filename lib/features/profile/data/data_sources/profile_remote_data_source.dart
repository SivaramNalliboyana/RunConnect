import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);

  Future<MyEventsBucket> getMyEvents(String userId);

  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  });

  Future<void> followUser({
    required String followerId,
    required String followeeId,
  });

  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  });

  Future<List<PastActivity>> getPastActivities(String userId);

  Future<List<ProfileSummary>> getFollowing(String userId);

  Future<List<ProfileSummary>> getFollowers(String userId);

  Future<List<ProfileSummary>> getEventParticipants(String eventId);
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
        _client
            .from('follows')
            .count(CountOption.exact)
            .eq('follower_id', userId),
        _client
            .from('follows')
            .count(CountOption.exact)
            .eq('followee_id', userId),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      final eventsOrganized = results[1] as int;
      final eventsJoined = results[2] as int;
      final followingCount = results[3] as int;
      final followersCount = results[4] as int;

      return UserProfile(
        id: profile['id'] as String,
        displayName: (profile['name'] as String?) ?? 'Runner',
        avatarUrl: profile['avatar_url'] as String?,
        followingCount: followingCount,
        followersCount: followersCount,
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
      const eventColumns =
          'id, title, distance_km, max_participants, pace_level, starts_at, '
          'meeting_point, image_url, host_id, '
          'participants:event_participants(count)';
      final results = await Future.wait<dynamic>([
        _client.from('events').select(eventColumns).eq('host_id', userId),
        _client
            .from('event_participants')
            .select('event:events!inner($eventColumns)')
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
    final participants = row['participants'] as List?;
    final currentParticipants =
        (participants != null && participants.isNotEmpty)
        ? (participants.first['count'] as int? ?? 0)
        : 0;

    return ProfileEventItem(
      id: row['id'] as String,
      title: row['title'] as String,
      startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
      distanceKm: (row['distance_km'] as num).toDouble(),
      maxParticipants: row['max_participants'] as int,
      currentParticipants: currentParticipants,
      paceLevel: PaceLevel.values.byName(row['pace_level'] as String),
      meetingPoint: row['meeting_point'] as String,
      imageUrl: row['image_url'] as String?,
      isHosting: (row['host_id'] as String?) == userId,
    );
  }

  @override
  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      final row = await _client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', followerId)
          .eq('followee_id', followeeId)
          .maybeSingle();
      return row != null;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> followUser({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      await _client.from('follows').insert({
        'follower_id': followerId,
        'followee_id': followeeId,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') return;
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      await _client
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('followee_id', followeeId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<PastActivity>> getPastActivities(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileSummary>> getFollowing(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('follows')
            .select('profile:profiles!followee_id(id, name, avatar_url)')
            .eq('follower_id', userId),
        _viewerFollowees(),
      ]);

      final rows = (results[0] as List).cast<Map<String, dynamic>>();
      final viewerFollowees = results[1] as Set<String>;
      return _toSummaries(rows, viewerFollowees);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<ProfileSummary>> getFollowers(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('follows')
            .select('profile:profiles!follower_id(id, name, avatar_url)')
            .eq('followee_id', userId),
        _viewerFollowees(),
      ]);

      final rows = (results[0] as List).cast<Map<String, dynamic>>();
      final viewerFollowees = results[1] as Set<String>;
      return _toSummaries(rows, viewerFollowees);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<ProfileSummary>> getEventParticipants(String eventId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('events')
            .select(
              'host_id,'
              ' host:profiles!host_id(id, name, avatar_url),'
              ' participants:event_participants('
              'profile:profiles!user_id(id, name, avatar_url))',
            )
            .eq('id', eventId)
            .single(),
        _viewerFollowees(),
      ]);

      final row = results[0] as Map<String, dynamic>;
      final viewerFollowees = results[1] as Set<String>;
      final viewerId = _client.auth.currentUser?.id;

      final hostId = row['host_id'] as String?;
      final host = row['host'] as Map<String, dynamic>?;
      final participantRows =
          (row['participants'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];

      final list = <ProfileSummary>[];
      final seen = <String>{};

      if (host != null && hostId != null) {
        list.add(
          ProfileSummary(
            id: hostId,
            displayName: (host['name'] as String?) ?? 'Runner',
            avatarUrl: host['avatar_url'] as String?,
            isFollowing: viewerFollowees.contains(hostId),
            isHost: true,
          ),
        );
        seen.add(hostId);
      }

      for (final p in participantRows) {
        final profile = p['profile'] as Map<String, dynamic>?;
        if (profile == null) continue;
        final id = profile['id'] as String;
        if (!seen.add(id)) continue;
        list.add(
          ProfileSummary(
            id: id,
            displayName: (profile['name'] as String?) ?? 'Runner',
            avatarUrl: profile['avatar_url'] as String?,
            isFollowing: id != viewerId && viewerFollowees.contains(id),
          ),
        );
      }
      return list;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  Future<Set<String>> _viewerFollowees() async {
    final viewerId = _client.auth.currentUser?.id;
    if (viewerId == null) return <String>{};
    final rows = await _client
        .from('follows')
        .select('followee_id')
        .eq('follower_id', viewerId);
    return (rows as List)
        .map((r) => (r as Map<String, dynamic>)['followee_id'] as String)
        .toSet();
  }

  List<ProfileSummary> _toSummaries(
    List<Map<String, dynamic>> rows,
    Set<String> viewerFollowees,
  ) {
    final viewerId = _client.auth.currentUser?.id;
    final list = <ProfileSummary>[];
    for (final row in rows) {
      final profile = row['profile'] as Map<String, dynamic>?;
      if (profile == null) continue;
      final id = profile['id'] as String;
      list.add(
        ProfileSummary(
          id: id,
          displayName: (profile['name'] as String?) ?? 'Runner',
          avatarUrl: profile['avatar_url'] as String?,
          isFollowing: id != viewerId && viewerFollowees.contains(id),
        ),
      );
    }
    return list;
  }
}
