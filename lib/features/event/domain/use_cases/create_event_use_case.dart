import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  final EventRepository _repository;
  CreateEventUseCase(this._repository);

  Future<Event> call({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
    XFile? image,
  }) {
    return _repository.createEvent(
      title: title,
      distanceKm: distanceKm,
      maxParticipants: maxParticipants,
      paceLevel: paceLevel,
      startsAt: startsAt,
      meetingPoint: meetingPoint,
      lat: lat,
      lng: lng,
      image: image,
    );
  }
}
