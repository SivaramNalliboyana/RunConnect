import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_followers_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/pages/follow_list_page.dart';
import 'follow_list_event.dart';
import 'follow_list_state.dart';

class FollowListBloc extends Bloc<FollowListEvent, FollowListState> {
  final GetFollowingUseCase _getFollowing;
  final GetFollowersUseCase _getFollowers;
  final FollowUserUseCase _followUser;
  final UnfollowUserUseCase _unfollowUser;
  final String _userId;
  final String _currentUserId;
  final FollowListMode _mode;

  FollowListBloc({
    required GetFollowingUseCase getFollowing,
    required GetFollowersUseCase getFollowers,
    required FollowUserUseCase followUser,
    required UnfollowUserUseCase unfollowUser,
    required String userId,
    required String currentUserId,
    required FollowListMode mode,
  }) : _getFollowing = getFollowing,
       _getFollowers = getFollowers,
       _followUser = followUser,
       _unfollowUser = unfollowUser,
       _userId = userId,
       _currentUserId = currentUserId,
       _mode = mode,
       super(const FollowListState.initial()) {
    on<FollowListRequested>(_onRequested);
    on<FollowListToggleRequested>(_onToggle);
  }

  Future<void> _onRequested(
    FollowListRequested event,
    Emitter<FollowListState> emit,
  ) async {
    emit(state.copyWith(
      status: FollowListStatus.loading,
      errorMessage: null,
    ));
    try {
      final users = _mode == FollowListMode.following
          ? await _getFollowing(_userId)
          : await _getFollowers(_userId);
      emit(state.copyWith(status: FollowListStatus.success, users: users));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: FollowListStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggle(
    FollowListToggleRequested event,
    Emitter<FollowListState> emit,
  ) async {
    if (_currentUserId.isEmpty) return;
    final targetId = event.targetUserId;
    if (state.mutatingIds.contains(targetId)) return;

    final index = state.users.indexWhere((u) => u.id == targetId);
    if (index < 0) return;
    final original = state.users[index];

    final updated = List<ProfileSummary>.from(state.users);
    updated[index] = original.copyWith(isFollowing: !original.isFollowing);

    final pending = {...state.mutatingIds, targetId};
    emit(state.copyWith(
      users: updated,
      mutatingIds: pending,
      actionErrorMessage: null,
    ));

    try {
      if (original.isFollowing) {
        await _unfollowUser(
          followerId: _currentUserId,
          followeeId: targetId,
        );
      } else {
        await _followUser(
          followerId: _currentUserId,
          followeeId: targetId,
        );
      }
      emit(state.copyWith(
        mutatingIds: state.mutatingIds.difference({targetId}),
      ));
    } on Failure catch (e) {
      final reverted = List<ProfileSummary>.from(state.users);
      reverted[index] = original;
      emit(state.copyWith(
        users: reverted,
        mutatingIds: state.mutatingIds.difference({targetId}),
        actionErrorMessage: e.message,
      ));
    } catch (e) {
      final reverted = List<ProfileSummary>.from(state.users);
      reverted[index] = original;
      emit(state.copyWith(
        users: reverted,
        mutatingIds: state.mutatingIds.difference({targetId}),
        actionErrorMessage: e.toString(),
      ));
    }
  }
}
