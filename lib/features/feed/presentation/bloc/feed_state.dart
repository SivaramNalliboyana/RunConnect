import 'package:runconnect/features/event/domain/entities/event.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState {
  final FeedStatus status;
  final List<Event> events;
  final Set<String> joinedEventIds;
  final String? errorMessage;
  final String? joinErrorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.events = const [],
    this.joinedEventIds = const {},
    this.errorMessage,
    this.joinErrorMessage,
  });

  const FeedState.initial() : this();

  FeedState copyWith({
    FeedStatus? status,
    List<Event>? events,
    Set<String>? joinedEventIds,
    String? errorMessage,
    String? joinErrorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      events: events ?? this.events,
      joinedEventIds: joinedEventIds ?? this.joinedEventIds,
      errorMessage: errorMessage,
      joinErrorMessage: joinErrorMessage,
    );
  }
}
