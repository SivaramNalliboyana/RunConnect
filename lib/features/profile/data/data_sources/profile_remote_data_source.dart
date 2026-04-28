import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);

  Future<List<PastActivity>> getPastActivities(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;
  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<UserProfile> getUserProfile(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<PastActivity>> getPastActivities(String userId) {
    throw UnimplementedError();
  }
}
