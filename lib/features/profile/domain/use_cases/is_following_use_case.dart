import '../repositories/profile_repository.dart';

class IsFollowingUseCase {
  final ProfileRepository _repository;
  IsFollowingUseCase(this._repository);

  Future<bool> call({
    required String followerId,
    required String followeeId,
  }) =>
      _repository.isFollowing(followerId: followerId, followeeId: followeeId);
}
