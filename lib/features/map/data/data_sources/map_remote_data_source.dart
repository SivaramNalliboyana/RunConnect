import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MapRemoteDataSource {
  Future<List<Event>> getEventsInRadius({
    required double lat,
    required double lng,
    required double radiusKm,
  });
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final SupabaseClient _client;
  MapRemoteDataSourceImpl(this._client);

  @override
  Future<List<Event>> getEventsInRadius({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final rows = await _client
          .rpc(
            'get_events_in_radius',
            params: {
              'p_lat': lat,
              'p_lng': lng,
              'p_radius_km': radiusKm,
            },
          )
          .select(
            '*, host:profiles!host_id(name, avatar_url),'
            ' participants:event_participants(count)',
          );

      return (rows as List).map(_mapRow).toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  Event _mapRow(dynamic row) {
    final map = row as Map<String, dynamic>;
    final host = map['host'] as Map<String, dynamic>?;
    final participants = map['participants'] as List?;
    final currentParticipants = (participants != null && participants.isNotEmpty)
        ? (participants.first['count'] as int? ?? 0)
        : 0;

    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      distanceKm: (map['distance_km'] as num).toDouble(),
      maxParticipants: map['max_participants'] as int,
      currentParticipants: currentParticipants,
      paceLevel: PaceLevel.values.byName(map['pace_level'] as String),
      startsAt: DateTime.parse(map['starts_at'] as String),
      meetingPoint: map['meeting_point'] as String,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      imageUrl: map['image_url'] as String?,
      hostId: map['host_id'] as String,
      hostName: (host?['name'] as String?) ?? 'Runner',
      hostAvatarUrl: host?['avatar_url'] as String?,
    );
  }
}
