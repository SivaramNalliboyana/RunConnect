import '../repositories/profile_repository.dart';

class UnfollowUserUseCase {
  final ProfileRepository _repository;
  UnfollowUserUseCase(this._repository);

  Future<void> call({
    required String followerId,
    required String followeeId,
  }) =>
      _repository.unfollowUser(followerId: followerId, followeeId: followeeId);
}
