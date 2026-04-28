import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import '../repositories/profile_repository.dart';

class GetFollowingUseCase {
  final ProfileRepository _repository;
  GetFollowingUseCase(this._repository);

  Future<List<ProfileSummary>> call(String userId) {
    throw UnimplementedError();
  }
}
