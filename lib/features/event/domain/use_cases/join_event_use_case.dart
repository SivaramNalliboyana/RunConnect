import 'package:runconnect/features/event/domain/repositories/event_repository.dart';

class JoinEventUseCase {
  final EventRepository _repository;
  JoinEventUseCase(this._repository);

  Future<void> call(String eventId) => _repository.joinEvent(eventId);
}
