import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getUserProfile(String userId);

  Future<MyEventsBucket> getMyEvents(String userId);

  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  });

  Future<void> followUser({
    required String followerId,
    required String followeeId,
  });

  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  });

  Future<List<PastActivity>> getPastActivities(String userId);

  Future<List<ProfileSummary>> getFollowing(String userId);

  Future<List<ProfileSummary>> getFollowers(String userId);
}
