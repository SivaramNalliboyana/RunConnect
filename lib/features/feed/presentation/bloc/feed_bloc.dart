import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/feed/domain/use_cases/get_events_use_case.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetEventsUseCase _getEvents;

  FeedBloc({required GetEventsUseCase getEvents})
    : _getEvents = getEvents,
      super(const FeedState.initial()) {
    on<FeedRequested>(_onRequested);
  }

  Future<void> _onRequested(
    FeedRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));
    try {
      final events = await _getEvents();
      emit(state.copyWith(status: FeedStatus.success, events: events));
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
}
