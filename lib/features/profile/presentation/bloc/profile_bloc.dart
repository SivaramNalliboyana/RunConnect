import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/use_cases/delete_event_use_case.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_my_events_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/is_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfile;
  final GetMyEventsUseCase _getMyEvents;
  final IsFollowingUseCase _isFollowing;
  final FollowUserUseCase _followUser;
  final UnfollowUserUseCase _unfollowUser;
  final DeleteEventUseCase _deleteEvent;
  final String _userId;
  final String _currentUserId;
  final bool _isCurrentUser;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfile,
    required GetMyEventsUseCase getMyEvents,
    required IsFollowingUseCase isFollowing,
    required FollowUserUseCase followUser,
    required UnfollowUserUseCase unfollowUser,
    required DeleteEventUseCase deleteEvent,
    required String userId,
    required String currentUserId,
    required bool isCurrentUser,
  }) : _getUserProfile = getUserProfile,
       _getMyEvents = getMyEvents,
       _isFollowing = isFollowing,
       _followUser = followUser,
       _unfollowUser = unfollowUser,
       _deleteEvent = deleteEvent,
       _userId = userId,
       _currentUserId = currentUserId,
       _isCurrentUser = isCurrentUser,
       super(ProfileState(isCurrentUserProfile: isCurrentUser)) {
    on<ProfileRequested>(_onRequested);
    on<MyEventDeleteRequested>(_onDeleteRequested);
    on<FollowToggleRequested>(_onFollowToggle);
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait([
        _getUserProfile(_userId),
        _getMyEvents(_userId),
        if (!_isCurrentUser && _currentUserId.isNotEmpty)
          _isFollowing(
            followerId: _currentUserId,
            followeeId: _userId,
          )
        else
          Future.value(false),
      ]);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: results[0] as UserProfile,
          myEvents: results[1] as MyEventsBucket,
          isCurrentUserProfile: _isCurrentUser,
          isFollowing: results[2] as bool,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    MyEventDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final previous = state.myEvents;

    final upcoming = previous.upcoming
        .where((e) => e.id != event.eventId)
        .toList(growable: false);
    final past = previous.past
        .where((e) => e.id != event.eventId)
        .toList(growable: false);

    emit(
      state.copyWith(
        myEvents: MyEventsBucket(upcoming: upcoming, past: past),
        actionErrorMessage: null,
      ),
    );

    try {
      await _deleteEvent(event.eventId);
    } on Failure catch (e) {
      emit(
        state.copyWith(
          myEvents: previous,
          actionErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          myEvents: previous,
          actionErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFollowToggle(
    FollowToggleRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (_isCurrentUser || _currentUserId.isEmpty) return;
    if (state.isFollowMutating) return;
    final profile = state.profile;
    if (profile == null) return;

    final wasFollowing = state.isFollowing;
    final updatedProfile = UserProfile(
      id: profile.id,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      followingCount: profile.followingCount,
      followersCount: profile.followersCount + (wasFollowing ? -1 : 1),
      totalKmRun: profile.totalKmRun,
      eventsJoined: profile.eventsJoined,
      eventsOrganized: profile.eventsOrganized,
    );

    emit(
      state.copyWith(
        isFollowing: !wasFollowing,
        profile: updatedProfile,
        isFollowMutating: true,
        actionErrorMessage: null,
      ),
    );

    try {
      if (wasFollowing) {
        await _unfollowUser(
          followerId: _currentUserId,
          followeeId: _userId,
        );
      } else {
        await _followUser(
          followerId: _currentUserId,
          followeeId: _userId,
        );
      }
      emit(state.copyWith(isFollowMutating: false));
    } on Failure catch (e) {
      emit(
        state.copyWith(
          isFollowing: wasFollowing,
          profile: profile,
          isFollowMutating: false,
          actionErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isFollowing: wasFollowing,
          profile: profile,
          isFollowMutating: false,
          actionErrorMessage: e.toString(),
        ),
      );
    }
  }
}
