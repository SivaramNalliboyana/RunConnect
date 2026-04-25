import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:runconnect/core/router/app_router.dart';
import 'package:runconnect/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const RunConnectApp());
}

class RunConnectApp extends StatelessWidget {
  const RunConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RunConnect',
      routerConfig: appRouter,
      theme: appTheme,
    );
  }
}
