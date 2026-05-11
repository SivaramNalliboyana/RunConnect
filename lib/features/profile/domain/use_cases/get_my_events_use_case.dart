import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import '../repositories/profile_repository.dart';

class GetMyEventsUseCase {
  final ProfileRepository _repository;
  GetMyEventsUseCase(this._repository);

  Future<MyEventsBucket> call(String userId) =>
      _repository.getMyEvents(userId);
}
