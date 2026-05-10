import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository _repository;
  GetUserProfileUseCase(this._repository);

  Future<UserProfile> call(String userId) => _repository.getUserProfile(userId);
}
