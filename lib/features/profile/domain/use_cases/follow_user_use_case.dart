import '../repositories/profile_repository.dart';

class FollowUserUseCase {
  final ProfileRepository _repository;
  FollowUserUseCase(this._repository);

  Future<void> call({
    required String followerId,
    required String followeeId,
  }) =>
      _repository.followUser(followerId: followerId, followeeId: followeeId);
}
