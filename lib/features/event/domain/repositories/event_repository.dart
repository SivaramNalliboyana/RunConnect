import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';

abstract class EventRepository {
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
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
  });

  Future<void> deleteEvent(String eventId);

  Future<void> joinEvent(String eventId);
  Future<void> leaveEvent(String eventId);
}
