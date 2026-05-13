import 'dart:typed_data';

import 'package:runconnect/features/event/domain/entities/event.dart';

abstract class EventRepository {
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
    Uint8List? imageBytes,
    String? imageMimeType,
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
