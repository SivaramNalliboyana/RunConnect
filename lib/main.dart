import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:runconnect/core/secrets/app_secrets.dart';
import 'package:runconnect/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:runconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:runconnect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runconnect/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:runconnect/core/router/app_router.dart';
import 'package:runconnect/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.annonkey,
  );
  runApp(const RunConnectApp());
}

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

class RunConnectApp extends StatelessWidget {
  const RunConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildAuthBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'RunConnect',
        routerConfig: appRouter,
        theme: appTheme,
        builder: (context, child) => BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) appRouter.go('/feed');
            if (state is AuthUnauthenticated) appRouter.go('/auth');
          },
          child: child!,
        ),
      ),
    );
  }
}
