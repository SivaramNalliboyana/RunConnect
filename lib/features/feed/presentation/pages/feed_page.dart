import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/feed/data/data_sources/feed_remote_data_source.dart';
import 'package:runconnect/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:runconnect/features/feed/domain/use_cases/get_events_use_case.dart';
import 'package:runconnect/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:runconnect/features/feed/presentation/bloc/feed_event.dart';
import 'package:runconnect/features/feed/presentation/bloc/feed_state.dart';
import 'package:runconnect/features/feed/presentation/widgets/feed_event_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc()..add(FeedRequested()),
      child: const _FeedView(),
    );
  }

  static FeedBloc _buildBloc() {
    final client = Supabase.instance.client;
    final dataSource = FeedRemoteDataSourceImpl(client);
    final repository = FeedRepositoryImpl(dataSource);
    return FeedBloc(getEvents: GetEventsUseCase(repository));
  }
}

class _FeedView extends StatelessWidget {
  const _FeedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.directions_run,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'RunConnect',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: _FeedBody()),
        ],
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        switch (state.status) {
          case FeedStatus.initial:
          case FeedStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          case FeedStatus.failure:
            return _ErrorView(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () => context.read<FeedBloc>().add(FeedRequested()),
            );
          case FeedStatus.success:
            if (state.events.isEmpty) {
              return const _EmptyView();
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<FeedBloc>().add(FeedRequested());
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: state.events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return FeedEventCard(
                    event: state.events[index],
                    onJoinPressed: () {},
                  );
                },
              ),
            );
        }
      },
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.directions_run,
            size: 56,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            'No upcoming events yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Be the first to create one!',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
