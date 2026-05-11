abstract class ProfileEvent {}

class ProfileRequested extends ProfileEvent {}

class MyEventDeleteRequested extends ProfileEvent {
  final String eventId;
  MyEventDeleteRequested(this.eventId);
}
