import 'package:runconnect/features/event/domain/entities/event.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState {
  final FeedStatus status;
  final List<Event> events;
  final String? errorMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.events = const [],
    this.errorMessage,
  });

  const FeedState.initial() : this();

  FeedState copyWith({
    FeedStatus? status,
    List<Event>? events,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      events: events ?? this.events,
      errorMessage: errorMessage,
    );
  }
}
