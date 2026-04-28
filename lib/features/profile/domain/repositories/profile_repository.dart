import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String userId);

  Future<List<PastActivity>> getPastActivities(String userId);
}
