import 'package:runconnect/features/event/domain/entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository _repository;
  UpdateEventUseCase(this._repository);

  Future<Event> call({
    required String eventId,
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
  }) {
    return _repository.updateEvent(
      eventId: eventId,
      title: title,
      distanceKm: distanceKm,
      maxParticipants: maxParticipants,
      paceLevel: paceLevel,
      startsAt: startsAt,
      meetingPoint: meetingPoint,
    );
  }
}
