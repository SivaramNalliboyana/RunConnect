import 'dart:typed_data';

import 'package:runconnect/features/event/domain/entities/event.dart';

class CreateEventState {
  final Uint8List? imageBytes;
  final String? imageMimeType;
  final PaceLevel? paceLevel;
  final bool isSubmitting;
  final String? errorMessage;
  final Event? savedEvent;

  const CreateEventState({
    this.imageBytes,
    this.imageMimeType,
    this.paceLevel,
    this.isSubmitting = false,
    this.errorMessage,
    this.savedEvent,
  });

  const CreateEventState.initial() : this();

  CreateEventState copyWith({
    Uint8List? imageBytes,
    String? imageMimeType,
    PaceLevel? paceLevel,
    bool? isSubmitting,
    String? errorMessage,
    Event? savedEvent,
  }) {
    return CreateEventState(
      imageBytes: imageBytes ?? this.imageBytes,
      imageMimeType: imageMimeType ?? this.imageMimeType,
      paceLevel: paceLevel ?? this.paceLevel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      savedEvent: savedEvent ?? this.savedEvent,
    );
  }
}
