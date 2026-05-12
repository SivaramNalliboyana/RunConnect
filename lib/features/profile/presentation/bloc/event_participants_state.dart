import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';

enum EventParticipantsStatus { initial, loading, success, failure }

class EventParticipantsState {
  final EventParticipantsStatus status;
  final List<ProfileSummary> users;
  final Set<String> mutatingIds;
  final String? errorMessage;
  final String? actionErrorMessage;

  const EventParticipantsState({
    this.status = EventParticipantsStatus.initial,
    this.users = const [],
    this.mutatingIds = const {},
    this.errorMessage,
    this.actionErrorMessage,
  });

  const EventParticipantsState.initial() : this();

  EventParticipantsState copyWith({
    EventParticipantsStatus? status,
    List<ProfileSummary>? users,
    Set<String>? mutatingIds,
    String? errorMessage,
    String? actionErrorMessage,
  }) {
    return EventParticipantsState(
      status: status ?? this.status,
      users: users ?? this.users,
      mutatingIds: mutatingIds ?? this.mutatingIds,
      errorMessage: errorMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }
}
