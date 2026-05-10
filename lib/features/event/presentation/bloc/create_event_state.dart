import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';

class CreateEventState {
  final XFile? image;
  final PaceLevel? paceLevel;
  final bool isSubmitting;
  final String? errorMessage;
  final Event? createdEvent;

  const CreateEventState({
    this.image,
    this.paceLevel,
    this.isSubmitting = false,
    this.errorMessage,
    this.createdEvent,
  });

  const CreateEventState.initial() : this();

  String? get imagePath => image?.path;

  CreateEventState copyWith({
    XFile? image,
    PaceLevel? paceLevel,
    bool? isSubmitting,
    String? errorMessage,
    Event? createdEvent,
  }) {
    return CreateEventState(
      image: image ?? this.image,
      paceLevel: paceLevel ?? this.paceLevel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      createdEvent: createdEvent ?? this.createdEvent,
    );
  }
}
