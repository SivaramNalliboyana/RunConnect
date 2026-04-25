import 'package:go_router/go_router.dart';
import 'package:runconnect/features/auth/presentation/pages/auth_page.dart';

final appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
  ],
);
