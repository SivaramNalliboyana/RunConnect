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
}
