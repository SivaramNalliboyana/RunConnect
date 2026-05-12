import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/repositories/profile_repository.dart';

class GetEventParticipantsUseCase {
  final ProfileRepository _repository;
  GetEventParticipantsUseCase(this._repository);

  Future<List<ProfileSummary>> call(String eventId) =>
      _repository.getEventParticipants(eventId);
}
