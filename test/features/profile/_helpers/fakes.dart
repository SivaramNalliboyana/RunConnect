import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/event/domain/repositories/event_repository.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/repositories/profile_repository.dart';

const kTargetUserId = 'target-user';
const kCurrentUserId = 'current-user';

UserProfile sampleProfile({
  String id = kTargetUserId,
  String displayName = 'Test Runner',
  int followersCount = 10,
  int followingCount = 5,
  double totalKmRun = 42.5,
  int eventsJoined = 3,
  int eventsOrganized = 1,
}) {
  return UserProfile(
    id: id,
    displayName: displayName,
    avatarUrl: null,
    followingCount: followingCount,
    followersCount: followersCount,
    totalKmRun: totalKmRun,
    eventsJoined: eventsJoined,
    eventsOrganized: eventsOrganized,
  );
}

ProfileEventItem sampleEvent(
  String id, {
  String title = 'Event',
  bool isHosting = true,
  DateTime? startsAt,
}) {
  return ProfileEventItem(
    id: id,
    title: '$title $id',
    startsAt: startsAt ?? DateTime(2026, 6, 1, 18),
    distanceKm: 5,
    maxParticipants: 20,
    currentParticipants: 5,
    paceLevel: PaceLevel.intermediate,
    meetingPoint: 'Park',
    isHosting: isHosting,
  );
}

class FakeProfileRepository implements ProfileRepository {
  UserProfile? profile;
  MyEventsBucket events = const MyEventsBucket.empty();
  bool followingStatus = false;

  Object? getUserProfileError;
  Object? getMyEventsError;
  Object? followError;
  Object? unfollowError;

  int followCalls = 0;
  int unfollowCalls = 0;
  String? lastFollowerId;
  String? lastFolloweeId;

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    if (getUserProfileError != null) throw getUserProfileError!;
    return profile ?? sampleProfile(id: userId);
  }

  @override
  Future<MyEventsBucket> getMyEvents(String userId) async {
    if (getMyEventsError != null) throw getMyEventsError!;
    return events;
  }

  @override
  Future<bool> isFollowing({
    required String followerId,
    required String followeeId,
  }) async => followingStatus;

  @override
  Future<void> followUser({
    required String followerId,
    required String followeeId,
  }) async {
    followCalls++;
    lastFollowerId = followerId;
    lastFolloweeId = followeeId;
    if (followError != null) throw followError!;
  }

  @override
  Future<void> unfollowUser({
    required String followerId,
    required String followeeId,
  }) async {
    unfollowCalls++;
    lastFollowerId = followerId;
    lastFolloweeId = followeeId;
    if (unfollowError != null) throw unfollowError!;
  }

  @override
  Future<List<PastActivity>> getPastActivities(String userId) async => const [];

  @override
  Future<List<ProfileSummary>> getFollowing(String userId) async => const [];

  @override
  Future<List<ProfileSummary>> getFollowers(String userId) async => const [];

  @override
  Future<List<ProfileSummary>> getEventParticipants(String eventId) async =>
      const [];
}

class FakeEventRepository implements EventRepository {
  Object? deleteError;
  int deleteCalls = 0;
  String? lastDeletedId;

  @override
  Future<void> deleteEvent(String eventId) async {
    deleteCalls++;
    lastDeletedId = eventId;
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
    XFile? image,
  }) => throw UnimplementedError();

  @override
  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
  }) => throw UnimplementedError();

  @override
  Future<void> joinEvent(String eventId) => throw UnimplementedError();

  @override
  Future<void> leaveEvent(String eventId) => throw UnimplementedError();
}
