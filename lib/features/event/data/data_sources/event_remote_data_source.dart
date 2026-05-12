import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class EventRemoteDataSource {
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
    XFile? image,
  });

  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
  });

  Future<void> deleteEvent(String eventId);

  Future<void> joinEvent(String eventId);
  Future<void> leaveEvent(String eventId);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client;
  EventRemoteDataSourceImpl(this._client);

  static const _bucket = 'event-images';
  static const _table = 'events';

  @override
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
    XFile? image,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in to create an event');
    }

    String? imageUrl;
    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final ext = image.path.split('.').last;
        final path = '${user.id}/${const Uuid().v4()}.$ext';

        await _client.storage
            .from(_bucket)
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$ext'),
            );

        imageUrl = _client.storage.from(_bucket).getPublicUrl(path);
      } on StorageException catch (e) {
        throw ServerFailure('Failed to upload image: ${e.message}');
      }
    }

    try {
      final inserted = await _client
          .from(_table)
          .insert({
            'host_id': user.id,
            'title': title,
            'distance_km': distanceKm,
            'max_participants': maxParticipants,
            'pace_level': paceLevel.name,
            'starts_at': startsAt.toUtc().toIso8601String(),
            'meeting_point': meetingPoint,
            'lat': lat,
            'lng': lng,
            'image_url': imageUrl,
          })
          .select()
          .single();

      final meta = user.userMetadata ?? const <String, dynamic>{};
      return Event(
        id: inserted['id'] as String,
        title: inserted['title'] as String,
        distanceKm: (inserted['distance_km'] as num).toDouble(),
        maxParticipants: inserted['max_participants'] as int,
        paceLevel: PaceLevel.values.byName(inserted['pace_level'] as String),
        startsAt: DateTime.parse(inserted['starts_at'] as String),
        meetingPoint: inserted['meeting_point'] as String,
        lat: (inserted['lat'] as num?)?.toDouble(),
        lng: (inserted['lng'] as num?)?.toDouble(),
        imageUrl: inserted['image_url'] as String?,
        hostId: user.id,
        hostName: (meta['name'] as String?) ?? 'Runner',
        hostAvatarUrl: meta['avatar_url'] as String?,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in to edit an event');
    }

    try {
      final updated = await _client
          .from(_table)
          .update({
            'title': title,
            'distance_km': distanceKm,
            'max_participants': maxParticipants,
            'pace_level': paceLevel.name,
            'starts_at': startsAt.toUtc().toIso8601String(),
            'meeting_point': meetingPoint,
            'lat': lat,
            'lng': lng,
          })
          .eq('id', eventId)
          .eq('host_id', user.id)
          .select(
            '*, host:profiles!host_id(name, avatar_url),'
            ' participants:event_participants(count)',
          )
          .single();

      final host = updated['host'] as Map<String, dynamic>?;
      final participants = updated['participants'] as List?;
      final currentParticipants =
          (participants != null && participants.isNotEmpty)
          ? (participants.first['count'] as int? ?? 0)
          : 0;

      return Event(
        id: updated['id'] as String,
        title: updated['title'] as String,
        distanceKm: (updated['distance_km'] as num).toDouble(),
        maxParticipants: updated['max_participants'] as int,
        currentParticipants: currentParticipants,
        paceLevel: PaceLevel.values.byName(updated['pace_level'] as String),
        startsAt: DateTime.parse(updated['starts_at'] as String),
        meetingPoint: updated['meeting_point'] as String,
        lat: (updated['lat'] as num?)?.toDouble(),
        lng: (updated['lng'] as num?)?.toDouble(),
        imageUrl: updated['image_url'] as String?,
        hostId: updated['host_id'] as String,
        hostName: (host?['name'] as String?) ?? 'Runner',
        hostAvatarUrl: host?['avatar_url'] as String?,
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in to delete an event');
    }

    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', eventId)
          .eq('host_id', user.id);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> joinEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in to join an event');
    }

    try {
      await _client.from('event_participants').insert({
        'event_id': eventId,
        'user_id': user.id,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ServerFailure('You already joined this event');
      }
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ServerFailure('You must be signed in to leave an event');
    }

    try {
      await _client
          .from('event_participants')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', user.id);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
