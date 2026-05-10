import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import '../repositories/profile_repository.dart';

class GetPastActivitiesUseCase {
  final ProfileRepository _repository;
  GetPastActivitiesUseCase(this._repository);

  Future<List<PastActivity>> call(String userId) =>
      _repository.getPastActivities(userId);
}
