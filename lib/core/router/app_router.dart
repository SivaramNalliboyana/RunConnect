import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runconnect/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:runconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:runconnect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runconnect/features/auth/presentation/pages/auth_page.dart';
import 'package:runconnect/features/auth/presentation/pages/login_page.dart';

AuthBloc _buildAuthBloc() {
  final client = Supabase.instance.client;
  final dataSource = AuthRemoteDataSourceImpl(client);
  final repository = AuthRepositoryImpl(dataSource);
  return AuthBloc(
    signIn: SignInUseCase(repository),
    signUp: SignUpUseCase(repository),
    signOut: SignOutUseCase(repository),
  );
}

final appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => BlocProvider(
        create: (_) => _buildAuthBloc(),
        child: const AuthPage(),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
