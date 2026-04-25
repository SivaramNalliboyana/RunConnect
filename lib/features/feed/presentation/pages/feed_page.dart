import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runconnect/features/auth/presentation/bloc/auth_event.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
        child: Center(child: Text('Feed')),
      ),
    );
  }
}
