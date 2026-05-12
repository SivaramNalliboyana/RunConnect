import 'package:flutter_test/flutter_test.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/use_cases/delete_event_use_case.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_my_events_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/is_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/profile_state.dart';

import '../../_helpers/fakes.dart';

ProfileBloc _buildBloc({
  required FakeProfileRepository profileRepo,
  required FakeEventRepository eventRepo,
  String userId = kTargetUserId,
  String currentUserId = kCurrentUserId,
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

/// Subscribes to [bloc] *before* [action] runs and collects every state
/// emitted while the action's microtasks drain. Avoids the broadcast-stream
/// race that `bloc.stream.firstWhere(...)` is prone to.
Future<List<ProfileState>> _runAndCollect(
  ProfileBloc bloc,
  Future<void> Function() action,
) async {
  final emissions = <ProfileState>[];
  final sub = bloc.stream.listen(emissions.add);
  await action();
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  await sub.cancel();
  return emissions;
}

void main() {
  group('ProfileBloc', () {
    late FakeProfileRepository profileRepo;
    late FakeEventRepository eventRepo;

    setUp(() {
      profileRepo = FakeProfileRepository();
      eventRepo = FakeEventRepository();
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
          profileRepo.profile = sampleProfile();
          profileRepo.events = MyEventsBucket(
            upcoming: [sampleEvent('u1')],
            past: [sampleEvent('p1', isHosting: false)],
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
          expect(last.profile?.id, kTargetUserId);
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
        profileRepo.profile = sampleProfile();
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
        profileRepo.profile = sampleProfile();
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
        profileRepo.profile = sampleProfile();
        profileRepo.events = MyEventsBucket(
          upcoming: [sampleEvent('u1'), sampleEvent('u2')],
          past: [sampleEvent('p1', isHosting: false)],
        );

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
        profileRepo.profile = sampleProfile();
        profileRepo.events = MyEventsBucket(
          upcoming: [sampleEvent('u1'), sampleEvent('u2')],
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
          profileRepo.profile = sampleProfile(followersCount: 10);
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
          expect(profileRepo.lastFollowerId, kCurrentUserId);
          expect(profileRepo.lastFolloweeId, kTargetUserId);
          await bloc.close();
        },
      );

      test('unfollow path decrements followers count and calls unfollowUser',
          () async {
        profileRepo.profile = sampleProfile(followersCount: 10);
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
        profileRepo.profile = sampleProfile(followersCount: 10);
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
        profileRepo.profile = sampleProfile();

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
        profileRepo.profile = sampleProfile();

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
