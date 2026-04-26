import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(state.copyWith(imagePath: event.image.path));
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
    // TODO: implement using _createEvent
  }
}
