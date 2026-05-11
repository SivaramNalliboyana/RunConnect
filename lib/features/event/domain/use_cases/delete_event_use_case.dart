import '../repositories/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository _repository;
  DeleteEventUseCase(this._repository);

  Future<void> call(String eventId) => _repository.deleteEvent(eventId);
}
