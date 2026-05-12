import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:runconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:runconnect/features/profile/domain/use_cases/follow_user_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_followers_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_following_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/unfollow_user_use_case.dart';
import 'package:runconnect/features/profile/presentation/bloc/follow_list_bloc.dart';
import 'package:runconnect/features/profile/presentation/bloc/follow_list_event.dart';
import 'package:runconnect/features/profile/presentation/bloc/follow_list_state.dart';
import 'package:runconnect/features/profile/presentation/widgets/follow_user_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum FollowListMode { following, followers }

class FollowListPage extends StatelessWidget {
  const FollowListPage({super.key, required this.userId, required this.mode});

  final String userId;
  final FollowListMode mode;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id ?? '';
    final repository = ProfileRepositoryImpl(
      ProfileRemoteDataSourceImpl(client),
    );

    return BlocProvider(
      create: (_) => FollowListBloc(
        getFollowing: GetFollowingUseCase(repository),
        getFollowers: GetFollowersUseCase(repository),
        followUser: FollowUserUseCase(repository),
        unfollowUser: UnfollowUserUseCase(repository),
        userId: userId,
        currentUserId: currentUserId,
        mode: mode,
      )..add(FollowListRequested()),
      child: _FollowListView(mode: mode, currentUserId: currentUserId),
    );
  }
}

class _FollowListView extends StatelessWidget {
  const _FollowListView({required this.mode, required this.currentUserId});

  final FollowListMode mode;
  final String currentUserId;

  String get _title => mode == FollowListMode.following ? 'Following' : 'Followers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          _title,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<FollowListBloc, FollowListState>(
          listenWhen: (prev, curr) =>
              prev.actionErrorMessage != curr.actionErrorMessage &&
              curr.actionErrorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionErrorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          },
          builder: (context, state) {
            switch (state.status) {
              case FollowListStatus.initial:
              case FollowListStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              case FollowListStatus.failure:
                return _ErrorView(
                  message: state.errorMessage ?? 'Something went wrong',
                  onRetry: () =>
                      context.read<FollowListBloc>().add(FollowListRequested()),
                );
              case FollowListStatus.success:
                if (state.users.isEmpty) {
                  return _EmptyView(mode: mode);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.users.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0x14000000),
                    indent: 76,
                  ),
                  itemBuilder: (_, i) {
                    final user = state.users[i];
                    return FollowUserTile(
                      user: user,
                      isSelf: user.id == currentUserId,
                      onTap: () => context.push('/user/${user.id}'),
                      onTogglePressed: () => context
                          .read<FollowListBloc>()
                          .add(FollowListToggleRequested(user.id)),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.mode});

  final FollowListMode mode;

  @override
  Widget build(BuildContext context) {
    final label = mode == FollowListMode.following
        ? "Not following anyone yet"
        : "No followers yet";
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
