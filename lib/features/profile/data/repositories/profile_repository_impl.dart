import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      return await _dataSource.getUserProfile(userId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<MyEventsBucket> getMyEvents(String userId) async {
    try {
      return await _dataSource.getMyEvents(userId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      return await _dataSource.isFollowing(
        followerId: followerId,
        followeeId: followeeId,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> followUser({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      await _dataSource.followUser(
        followerId: followerId,
        followeeId: followeeId,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  }) async {
    try {
      await _dataSource.unfollowUser(
        followerId: followerId,
        followeeId: followeeId,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PastActivity>> getPastActivities(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileSummary>> getFollowing(String userId) async {
    try {
      return await _dataSource.getFollowing(userId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ProfileSummary>> getFollowers(String userId) async {
    try {
      return await _dataSource.getFollowers(userId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
