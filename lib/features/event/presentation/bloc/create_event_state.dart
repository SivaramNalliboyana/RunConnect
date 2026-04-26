import 'package:runconnect/features/event/domain/entities/event.dart';

class CreateEventState {
  final String? imagePath;
  final PaceLevel? paceLevel;
  final bool isSubmitting;
  final String? errorMessage;
  final Event? createdEvent;

  const CreateEventState({
    this.imagePath,
    this.paceLevel,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdEvent,
  });

  const CreateEventState.initial() : this();

  CreateEventState copyWith({
    String? imagePath,
    PaceLevel? paceLevel,
    bool? isSubmitting,
    String? errorMessage,
    Event? createdEvent,
  }) {
    return CreateEventState(
      imagePath: imagePath ?? this.imagePath,
      paceLevel: paceLevel ?? this.paceLevel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      createdEvent: createdEvent ?? this.createdEvent,
    );
  }
}
