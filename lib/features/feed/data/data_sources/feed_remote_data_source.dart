import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FeedRemoteDataSource {
  Future<List<Event>> getEvents();
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final SupabaseClient _client;
  FeedRemoteDataSourceImpl(this._client);

  @override
  Future<List<Event>> getEvents() async {
    try {
      final rows = await _client
          .from('events')
          .select('*, host:profiles!host_id(name, avatar_url)')
          .gte('starts_at', DateTime.now().toUtc().toIso8601String())
          .order('starts_at', ascending: true);

      return (rows as List).map(_mapRow).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  Event _mapRow(dynamic row) {
    final map = row as Map<String, dynamic>;
    final host = map['host'] as Map<String, dynamic>?;
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      distanceKm: (map['distance_km'] as num).toDouble(),
      maxParticipants: map['max_participants'] as int,
      paceLevel: PaceLevel.values.byName(map['pace_level'] as String),
      startsAt: DateTime.parse(map['starts_at'] as String),
      meetingPoint: map['meeting_point'] as String,
      imageUrl: map['image_url'] as String?,
      hostName: (host?['name'] as String?) ?? 'Runner',
      hostAvatarUrl: host?['avatar_url'] as String?,
    );
  }
}
