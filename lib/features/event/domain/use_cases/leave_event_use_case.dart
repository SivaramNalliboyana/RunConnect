import 'package:runconnect/features/event/domain/repositories/event_repository.dart';

class LeaveEventUseCase {
  final EventRepository _repository;
  LeaveEventUseCase(this._repository);

  Future<void> call(String eventId) => _repository.leaveEvent(eventId);
}
