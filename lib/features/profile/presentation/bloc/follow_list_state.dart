import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';

enum FollowListStatus { initial, loading, success, failure }

class FollowListState {
  final FollowListStatus status;
  final List<ProfileSummary> users;
  final Set<String> mutatingIds;
  final String? errorMessage;
  final String? actionErrorMessage;

  const FollowListState({
    this.status = FollowListStatus.initial,
    this.users = const [],
    this.mutatingIds = const {},
    this.errorMessage,
    this.actionErrorMessage,
  });

  const FollowListState.initial() : this();

  FollowListState copyWith({
    FollowListStatus? status,
    List<ProfileSummary>? users,
    Set<String>? mutatingIds,
    String? errorMessage,
    String? actionErrorMessage,
  }) {
    return FollowListState(
      status: status ?? this.status,
      users: users ?? this.users,
      mutatingIds: mutatingIds ?? this.mutatingIds,
      errorMessage: errorMessage,
      actionErrorMessage: actionErrorMessage,
    );
  }
}
