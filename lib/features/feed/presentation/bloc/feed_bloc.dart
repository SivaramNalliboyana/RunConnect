import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/event/domain/use_cases/join_event_use_case.dart';
import 'package:runconnect/features/event/domain/use_cases/leave_event_use_case.dart';
import 'package:runconnect/features/feed/domain/use_cases/get_events_use_case.dart';
import 'package:runconnect/features/feed/domain/use_cases/get_joined_event_ids_use_case.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetEventsUseCase _getEvents;
  final GetJoinedEventIdsUseCase _getJoinedIds;
  final JoinEventUseCase _joinEvent;
  final LeaveEventUseCase _leaveEvent;

  FeedBloc({
    required GetEventsUseCase getEvents,
    required GetJoinedEventIdsUseCase getJoinedIds,
    required JoinEventUseCase joinEvent,
    required LeaveEventUseCase leaveEvent,
  }) : _getEvents = getEvents,
       _getJoinedIds = getJoinedIds,
       _joinEvent = joinEvent,
       _leaveEvent = leaveEvent,
       super(const FeedState.initial()) {
    on<FeedRequested>(_onRequested);
    on<FeedEventJoinRequested>(_onJoinRequested);
    on<FeedEventLeaveRequested>(_onLeaveRequested);
  }

  Future<void> _onRequested(
    FeedRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait([
        _getEvents(),
        _getJoinedIds(),
      ]);
      emit(
        state.copyWith(
          status: FeedStatus.success,
          events: results[0] as List<Event>,
          joinedEventIds: results[1] as Set<String>,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(status: FeedStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onJoinRequested(
    FeedEventJoinRequested event,
    Emitter<FeedState> emit,
  ) async {
    final eventId = event.eventId;
    if (state.joinedEventIds.contains(eventId)) return;

    final previousEvents = state.events;
    final previousJoined = state.joinedEventIds;

    emit(
      state.copyWith(
        events: _withParticipantDelta(state.events, eventId, 1),
        joinedEventIds: {...state.joinedEventIds, eventId},
        joinErrorMessage: null,
      ),
    );

    try {
      await _joinEvent(eventId);
    } on Failure catch (e) {
      emit(
        state.copyWith(
          events: previousEvents,
          joinedEventIds: previousJoined,
          joinErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          events: previousEvents,
          joinedEventIds: previousJoined,
          joinErrorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLeaveRequested(
    FeedEventLeaveRequested event,
    Emitter<FeedState> emit,
  ) async {
    final eventId = event.eventId;
    if (!state.joinedEventIds.contains(eventId)) return;

    final previousEvents = state.events;
    final previousJoined = state.joinedEventIds;

    emit(
      state.copyWith(
        events: _withParticipantDelta(state.events, eventId, -1),
        joinedEventIds: {...state.joinedEventIds}..remove(eventId),
        joinErrorMessage: null,
      ),
    );

    try {
      await _leaveEvent(eventId);
    } on Failure catch (e) {
      emit(
        state.copyWith(
          events: previousEvents,
          joinedEventIds: previousJoined,
          joinErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          events: previousEvents,
          joinedEventIds: previousJoined,
          joinErrorMessage: e.toString(),
        ),
      );
    }
  }

  List<Event> _withParticipantDelta(
    List<Event> events,
    String eventId,
    int delta,
  ) {
    return events
        .map(
          (e) => e.id == eventId
              ? Event(
                  id: e.id,
                  title: e.title,
                  distanceKm: e.distanceKm,
                  maxParticipants: e.maxParticipants,
                  currentParticipants: (e.currentParticipants + delta)
                      .clamp(0, e.maxParticipants),
                  paceLevel: e.paceLevel,
                  startsAt: e.startsAt,
                  meetingPoint: e.meetingPoint,
                  imageUrl: e.imageUrl,
                  hostId: e.hostId,
                  hostName: e.hostName,
                  hostAvatarUrl: e.hostAvatarUrl,
                )
              : e,
        )
        .toList(growable: false);
  }
}
