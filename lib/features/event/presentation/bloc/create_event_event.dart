import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';

abstract class CreateEventEvent {}

class CreateEventImagePicked extends CreateEventEvent {
  final XFile image;
  CreateEventImagePicked(this.image);
}

class CreateEventPaceLevelSelected extends CreateEventEvent {
  final PaceLevel paceLevel;
  CreateEventPaceLevelSelected(this.paceLevel);
}

class CreateEventSubmitted extends CreateEventEvent {
  final String title;
  final double distanceKm;
  final int maxParticipants;
  final DateTime startsAt;
  final String meetingPoint;
  CreateEventSubmitted({
    required this.title,
    required this.distanceKm,
    required this.maxParticipants,
    required this.startsAt,
    required this.meetingPoint,
  });
}

class UpdateEventSubmitted extends CreateEventEvent {
  final String eventId;
  final String title;
  final double distanceKm;
  final int maxParticipants;
  final PaceLevel paceLevel;
  final DateTime startsAt;
  final String meetingPoint;
  UpdateEventSubmitted({
    required this.eventId,
    required this.title,
    required this.distanceKm,
    required this.maxParticipants,
    required this.paceLevel,
    required this.startsAt,
    required this.meetingPoint,
  });
}
