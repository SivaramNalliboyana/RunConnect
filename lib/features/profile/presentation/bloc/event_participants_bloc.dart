import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_event_participants_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';

import 'event_participants_event.dart';
import 'event_participants_state.dart';

class EventParticipantsBloc
    extends Bloc<EventParticipantsEvent, EventParticipantsState> {
  final GetEventParticipantsUseCase _getParticipants;
  final FollowUserUseCase _followUser;
  final UnfollowUserUseCase _unfollowUser;
  final String _eventId;
  final String _currentUserId;

  EventParticipantsBloc({
    required GetEventParticipantsUseCase getParticipants,
    required FollowUserUseCase followUser,
    required UnfollowUserUseCase unfollowUser,
    required String eventId,
    required String currentUserId,
  })  : _getParticipants = getParticipants,
        _followUser = followUser,
        _unfollowUser = unfollowUser,
        _eventId = eventId,
        _currentUserId = currentUserId,
        super(const EventParticipantsState.initial()) {
    on<EventParticipantsRequested>(_onRequested);
    on<EventParticipantsToggleRequested>(_onToggle);
  }

  Future<void> _onRequested(
    EventParticipantsRequested event,
    Emitter<EventParticipantsState> emit,
  ) async {
    emit(state.copyWith(
      status: EventParticipantsStatus.loading,
      errorMessage: null,
    ));
    try {
      final users = await _getParticipants(_eventId);
      emit(state.copyWith(
        status: EventParticipantsStatus.success,
        users: users,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: EventParticipantsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EventParticipantsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggle(
    EventParticipantsToggleRequested event,
    Emitter<EventParticipantsState> emit,
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
