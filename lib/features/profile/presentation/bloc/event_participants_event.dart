abstract class EventParticipantsEvent {}

class EventParticipantsRequested extends EventParticipantsEvent {}

class EventParticipantsToggleRequested extends EventParticipantsEvent {
  final String targetUserId;
  EventParticipantsToggleRequested(this.targetUserId);
}
