import 'package:runconnect/features/profile/domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.initial() : this();

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}
