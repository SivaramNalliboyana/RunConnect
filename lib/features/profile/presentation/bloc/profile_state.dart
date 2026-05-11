import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState {
  final ProfileStatus status;
  final UserProfile? profile;
  final MyEventsBucket myEvents;
  final bool isCurrentUserProfile;
  final bool isFollowing;
  final bool isFollowMutating;
  final String? errorMessage;
  final String? actionErrorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.myEvents = const MyEventsBucket.empty(),
    this.isCurrentUserProfile = true,
    this.isFollowing = false,
    this.isFollowMutating = false,
    this.errorMessage,
    this.actionErrorMessage,
  });

  const ProfileState.initial() : this();

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    MyEventsBucket? myEvents,
    bool? isCurrentUserProfile,
    bool? isFollowing,
    bool? isFollowMutating,
    String? errorMessage,
    String? actionErrorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      myEvents: myEvents ?? this.myEvents,
      isCurrentUserProfile:
          isCurrentUserProfile ?? this.isCurrentUserProfile,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowMutating: isFollowMutating ?? this.isFollowMutating,
      errorMessage: errorMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }
}
