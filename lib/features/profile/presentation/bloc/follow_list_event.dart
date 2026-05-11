abstract class FollowListEvent {}

class FollowListRequested extends FollowListEvent {}

class FollowListToggleRequested extends FollowListEvent {
  final String targetUserId;
  FollowListToggleRequested(this.targetUserId);
}
