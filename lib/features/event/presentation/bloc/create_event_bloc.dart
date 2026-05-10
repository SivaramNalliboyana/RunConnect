import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/use_cases/create_event_use_case.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final CreateEventUseCase _createEvent;

  CreateEventBloc({required CreateEventUseCase createEvent})
    : _createEvent = createEvent,
      super(const CreateEventState.initial()) {
    on<CreateEventImagePicked>(_onImagePicked);
    on<CreateEventPaceLevelSelected>(_onPaceLevelSelected);
    on<CreateEventSubmitted>(_onSubmitted);
  }

  void _onImagePicked(
    CreateEventImagePicked event,
    Emitter<CreateEventState> emit,
  ) {
    emit(state.copyWith(image: event.image));
  }

  void _onPaceLevelSelected(
    CreateEventPaceLevelSelected event,
    Emitter<CreateEventState> emit,
  ) {
    emit(state.copyWith(paceLevel: event.paceLevel));
  }

  Future<void> _onSubmitted(
    CreateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    final paceLevel = state.paceLevel;
    if (paceLevel == null) {
      emit(state.copyWith(errorMessage: 'Select a pace level'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final created = await _createEvent(
        title: event.title,
        distanceKm: event.distanceKm,
        maxParticipants: event.maxParticipants,
        paceLevel: paceLevel,
        startsAt: event.startsAt,
        meetingPoint: event.meetingPoint,
        image: state.image,
      );
      emit(state.copyWith(isSubmitting: false, createdEvent: created));
    } on Failure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
