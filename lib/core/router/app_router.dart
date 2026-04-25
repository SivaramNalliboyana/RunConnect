import 'package:go_router/go_router.dart';
import 'package:runconnect/core/presentation/pages/splash_page.dart';
import 'package:runconnect/features/auth/presentation/pages/auth_page.dart';
import 'package:runconnect/features/auth/presentation/pages/login_page.dart';
import 'package:runconnect/features/feed/presentation/pages/feed_page.dart';

final appRouter = GoRouter(
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
      path: '/feed',
      builder: (context, state) => const FeedPage(),
    ),
  ],
);
