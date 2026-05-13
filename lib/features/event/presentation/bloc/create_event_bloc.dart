import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/use_cases/create_event_use_case.dart';
import 'package:runconnect/features/event/domain/use_cases/update_event_use_case.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final CreateEventUseCase _createEvent;
  final UpdateEventUseCase? _updateEvent;

  CreateEventBloc({
    required CreateEventUseCase createEvent,
    UpdateEventUseCase? updateEvent,
  }) : _createEvent = createEvent,
       _updateEvent = updateEvent,
       super(const CreateEventState.initial()) {
    on<CreateEventImagePicked>(_onImagePicked);
    on<CreateEventPaceLevelSelected>(_onPaceLevelSelected);
    on<CreateEventSubmitted>(_onSubmitted);
    on<UpdateEventSubmitted>(_onUpdateSubmitted);
  }

  void _onImagePicked(
    CreateEventImagePicked event,
    Emitter<CreateEventState> emit,
  ) {
    emit(state.copyWith(
      imageBytes: event.bytes,
      imageMimeType: event.mimeType,
    ));
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
        lat: event.lat,
        lng: event.lng,
        imageBytes: state.imageBytes,
        imageMimeType: state.imageMimeType,
      );
      emit(state.copyWith(isSubmitting: false, savedEvent: created));
    } on Failure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateSubmitted(
    UpdateEventSubmitted event,
    Emitter<CreateEventState> emit,
  ) async {
    final updateUseCase = _updateEvent;
    if (updateUseCase == null) {
      emit(state.copyWith(errorMessage: 'Edit not available'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final updated = await updateUseCase(
        eventId: event.eventId,
        title: event.title,
        distanceKm: event.distanceKm,
        maxParticipants: event.maxParticipants,
        paceLevel: event.paceLevel,
        startsAt: event.startsAt,
        meetingPoint: event.meetingPoint,
        lat: event.lat,
        lng: event.lng,
      );
      emit(state.copyWith(isSubmitting: false, savedEvent: updated));
    } on Failure catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
