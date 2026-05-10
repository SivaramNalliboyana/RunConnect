abstract class FeedEvent {}

class FeedRequested extends FeedEvent {}

class FeedEventJoinRequested extends FeedEvent {
  final String eventId;
  FeedEventJoinRequested(this.eventId);
}

class FeedEventLeaveRequested extends FeedEvent {
  final String eventId;
  FeedEventLeaveRequested(this.eventId);
}
