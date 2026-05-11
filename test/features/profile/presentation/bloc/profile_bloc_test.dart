import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/event/domain/repositories/event_repository.dart';
import 'package:runconnect/features/event/domain/use_cases/delete_event_use_case.dart';
import 'package:runconnect/features/profile/domain/entities/past_activity.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/profile_summary.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/repositories/profile_repository.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_my_events_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/is_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_state.dart';

const _targetUserId = 'target-user';
const _currentUserId = 'current-user';

UserProfile _profile({
  String id = _targetUserId,
  int followersCount = 10,
  int followingCount = 5,
}) {
  return UserProfile(
    id: id,
    displayName: 'Test Runner',
    avatarUrl: null,
    followingCount: followingCount,
    followersCount: followersCount,
    totalKmRun: 42.5,
    eventsJoined: 3,
    eventsOrganized: 1,
  );
}

ProfileEventItem _event(String id, {bool isHosting = true}) {
  return ProfileEventItem(
    id: id,
    title: 'Event $id',
    startsAt: DateTime(2026, 6, 1, 18),
    distanceKm: 5,
    maxParticipants: 20,
    currentParticipants: 5,
    paceLevel: PaceLevel.intermediate,
    meetingPoint: 'Park',
    isHosting: isHosting,
  );
}

class _FakeProfileRepository implements ProfileRepository {
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
    return profile ?? _profile(id: userId);
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
}

class _FakeEventRepository implements EventRepository {
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
  }) => throw UnimplementedError();

  @override
  Future<void> joinEvent(String eventId) => throw UnimplementedError();

  @override
  Future<void> leaveEvent(String eventId) => throw UnimplementedError();
}

ProfileBloc _buildBloc({
  required _FakeProfileRepository profileRepo,
  required _FakeEventRepository eventRepo,
  String userId = _targetUserId,
  String currentUserId = _currentUserId,
  bool isCurrentUser = false,
}) {
  return ProfileBloc(
    getUserProfile: GetUserProfileUseCase(profileRepo),
    getMyEvents: GetMyEventsUseCase(profileRepo),
    isFollowing: IsFollowingUseCase(profileRepo),
    followUser: FollowUserUseCase(profileRepo),
    unfollowUser: UnfollowUserUseCase(profileRepo),
    deleteEvent: DeleteEventUseCase(eventRepo),
    userId: userId,
    currentUserId: currentUserId,
    isCurrentUser: isCurrentUser,
  );
}

/// Collects every state emitted by [bloc] until [settle] resolves.
///
/// Subscribes *before* the caller's first event dispatch so no emissions are
/// missed on the broadcast stream.
Future<List<ProfileState>> _runAndCollect(
  ProfileBloc bloc,
  Future<void> Function() action,
) async {
  final emissions = <ProfileState>[];
  final sub = bloc.stream.listen(emissions.add);
  await action();
  // Yield a few times so any pending microtasks (the bloc's awaited futures)
  // finish before we snapshot.
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  await sub.cancel();
  return emissions;
}

void main() {
  group('ProfileBloc', () {
    late _FakeProfileRepository profileRepo;
    late _FakeEventRepository eventRepo;

    setUp(() {
      profileRepo = _FakeProfileRepository();
      eventRepo = _FakeEventRepository();
    });

    test('initial state has the isCurrentUserProfile flag set', () async {
      final bloc = _buildBloc(
        profileRepo: profileRepo,
        eventRepo: eventRepo,
        isCurrentUser: true,
      );
      expect(bloc.state.status, ProfileStatus.initial);
      expect(bloc.state.isCurrentUserProfile, isTrue);
      expect(bloc.state.profile, isNull);
      expect(bloc.state.isFollowing, isFalse);
      await bloc.close();
    });

    group('ProfileRequested', () {
      test(
        'loads profile and events for own profile, ignoring follow lookup',
        () async {
          profileRepo.profile = _profile();
          profileRepo.events = MyEventsBucket(
            upcoming: [_event('u1')],
            past: [_event('p1', isHosting: false)],
          );
          profileRepo.followingStatus = true;

          final bloc = _buildBloc(
            profileRepo: profileRepo,
            eventRepo: eventRepo,
            isCurrentUser: true,
          );

          final emissions = await _runAndCollect(bloc, () async {
            bloc.add(ProfileRequested());
          });

          expect(
            emissions.map((s) => s.status),
            [ProfileStatus.loading, ProfileStatus.success],
          );
          final last = emissions.last;
          expect(last.profile?.id, _targetUserId);
          expect(last.myEvents.upcoming, hasLength(1));
          expect(last.myEvents.past, hasLength(1));
          expect(
            last.isFollowing,
            isFalse,
            reason: 'follow status should not be queried for own profile',
          );
          expect(last.isCurrentUserProfile, isTrue);
          await bloc.close();
        },
      );

      test('loads follow status when viewing another user', () async {
        profileRepo.profile = _profile();
        profileRepo.followingStatus = true;

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: false,
        );

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final last = emissions.last;
        expect(last.status, ProfileStatus.success);
        expect(last.isFollowing, isTrue);
        expect(last.isCurrentUserProfile, isFalse);
        await bloc.close();
      });

      test('skips follow lookup when currentUserId is empty (logged out)',
          () async {
        profileRepo.profile = _profile();
        profileRepo.followingStatus = true;

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          currentUserId: '',
          isCurrentUser: false,
        );

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        expect(emissions.last.status, ProfileStatus.success);
        expect(emissions.last.isFollowing, isFalse);
        await bloc.close();
      });

      test('emits failure with Failure.message when repository throws Failure',
          () async {
        profileRepo.getUserProfileError = const ServerFailure('boom');

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: true,
        );

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        expect(emissions.last.status, ProfileStatus.failure);
        expect(emissions.last.errorMessage, 'boom');
        expect(emissions.last.profile, isNull);
        await bloc.close();
      });

      test('emits failure with toString() for generic exceptions', () async {
        profileRepo.getMyEventsError = Exception('network down');

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: true,
        );

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        expect(emissions.last.status, ProfileStatus.failure);
        expect(emissions.last.errorMessage, contains('network down'));
        await bloc.close();
      });
    });

    group('MyEventDeleteRequested', () {
      test('optimistically removes the event then calls deleteEvent',
          () async {
        profileRepo.profile = _profile();
        profileRepo.events = MyEventsBucket(
          upcoming: [_event('u1'), _event('u2')],
          past: [_event('p1', isHosting: false)],
        );

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: true,
        );

        // Prime: load profile first.
        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(MyEventDeleteRequested('u1'));
        });

        final last = emissions.last;
        expect(last.myEvents.upcoming.map((e) => e.id), ['u2']);
        expect(last.myEvents.past, hasLength(1));
        expect(last.actionErrorMessage, isNull);
        expect(eventRepo.deleteCalls, 1);
        expect(eventRepo.lastDeletedId, 'u1');
        await bloc.close();
      });

      test('rolls back and sets actionErrorMessage when delete fails',
          () async {
        profileRepo.profile = _profile();
        profileRepo.events = MyEventsBucket(
          upcoming: [_event('u1'), _event('u2')],
          past: const [],
        );
        eventRepo.deleteError = const ServerFailure('delete failed');

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: true,
        );

        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(MyEventDeleteRequested('u1'));
        });

        // First emission is optimistic removal; final emission restores list.
        expect(emissions.first.myEvents.upcoming.map((e) => e.id), ['u2']);
        final last = emissions.last;
        expect(last.myEvents.upcoming.map((e) => e.id), ['u1', 'u2']);
        expect(last.actionErrorMessage, 'delete failed');
        await bloc.close();
      });
    });

    group('FollowToggleRequested', () {
      test(
        'optimistically follows, bumps followers count, then settles',
        () async {
          profileRepo.profile = _profile(followersCount: 10);
          profileRepo.followingStatus = false;

          final bloc = _buildBloc(
            profileRepo: profileRepo,
            eventRepo: eventRepo,
            isCurrentUser: false,
          );

          await _runAndCollect(bloc, () async {
            bloc.add(ProfileRequested());
          });

          final emissions = await _runAndCollect(bloc, () async {
            bloc.add(FollowToggleRequested());
          });

          expect(emissions, hasLength(2));
          final optimistic = emissions.first;
          expect(optimistic.isFollowing, isTrue);
          expect(optimistic.isFollowMutating, isTrue);
          expect(optimistic.profile?.followersCount, 11);

          final settled = emissions.last;
          expect(settled.isFollowing, isTrue);
          expect(settled.isFollowMutating, isFalse);
          expect(settled.profile?.followersCount, 11);

          expect(profileRepo.followCalls, 1);
          expect(profileRepo.lastFollowerId, _currentUserId);
          expect(profileRepo.lastFolloweeId, _targetUserId);
          await bloc.close();
        },
      );

      test('unfollow path decrements followers count and calls unfollowUser',
          () async {
        profileRepo.profile = _profile(followersCount: 10);
        profileRepo.followingStatus = true;

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: false,
        );

        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(FollowToggleRequested());
        });

        final settled = emissions.last;
        expect(settled.isFollowing, isFalse);
        expect(settled.profile?.followersCount, 9);
        expect(settled.isFollowMutating, isFalse);
        expect(profileRepo.unfollowCalls, 1);
        expect(profileRepo.followCalls, 0);
        await bloc.close();
      });

      test('rolls back follow state and surfaces error when follow fails',
          () async {
        profileRepo.profile = _profile(followersCount: 10);
        profileRepo.followingStatus = false;
        profileRepo.followError = const ServerFailure('rls denied');

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: false,
        );

        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(FollowToggleRequested());
        });

        final settled = emissions.last;
        expect(settled.isFollowing, isFalse);
        expect(settled.profile?.followersCount, 10);
        expect(settled.isFollowMutating, isFalse);
        expect(settled.actionErrorMessage, 'rls denied');
        await bloc.close();
      });

      test('is a no-op on the current user\'s own profile', () async {
        profileRepo.profile = _profile();

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          isCurrentUser: true,
        );

        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final before = bloc.state;
        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(FollowToggleRequested());
        });

        expect(emissions, isEmpty,
            reason: 'no state changes should occur for own profile');
        expect(profileRepo.followCalls, 0);
        expect(profileRepo.unfollowCalls, 0);
        expect(bloc.state.isFollowing, before.isFollowing);
        expect(
          bloc.state.profile?.followersCount,
          before.profile?.followersCount,
        );
        await bloc.close();
      });

      test('is a no-op when currentUserId is empty', () async {
        profileRepo.profile = _profile();

        final bloc = _buildBloc(
          profileRepo: profileRepo,
          eventRepo: eventRepo,
          currentUserId: '',
          isCurrentUser: false,
        );

        await _runAndCollect(bloc, () async {
          bloc.add(ProfileRequested());
        });

        final emissions = await _runAndCollect(bloc, () async {
          bloc.add(FollowToggleRequested());
        });

        expect(emissions, isEmpty);
        expect(profileRepo.followCalls, 0);
        expect(profileRepo.unfollowCalls, 0);
        await bloc.close();
      });
    });
  });
}
