import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/presentation/pages/splash_page.dart';
import 'package:runconnect/core/presentation/scaffold/main_scaffold.dart';
import 'package:runconnect/features/auth/presentation/pages/auth_page.dart';
import 'package:runconnect/features/auth/presentation/pages/login_page.dart';
import 'package:runconnect/features/board/presentation/pages/board_page.dart';
import 'package:runconnect/features/event/presentation/pages/create_event_page.dart';
import 'package:runconnect/features/feed/presentation/pages/feed_page.dart';
import 'package:runconnect/features/map/presentation/pages/map_page.dart';
import 'package:runconnect/features/profile/presentation/pages/follow_list_page.dart';
import 'package:runconnect/features/profile/presentation/pages/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/create-event',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateEventPage(),
    ),
    GoRoute(
      path: '/profile/following',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          const FollowListPage(mode: FollowListMode.following),
    ),
    GoRoute(
      path: '/profile/followers',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          const FollowListPage(mode: FollowListMode.followers),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/board',
              builder: (context, state) => const BoardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
