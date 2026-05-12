import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/board/data/data_sources/board_remote_data_source.dart';
import 'package:runconnect/features/board/data/repositories/board_repository_impl.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';
import 'package:runconnect/features/board/domain/use_cases/get_leaderboard_use_case.dart';
import 'package:runconnect/features/board/presentation/bloc/board_bloc.dart';
import 'package:runconnect/features/board/presentation/bloc/board_event.dart';
import 'package:runconnect/features/board/presentation/bloc/board_state.dart';
import 'package:runconnect/features/board/presentation/widgets/leaderboard_row.dart';
import 'package:runconnect/features/board/presentation/widgets/podium_card.dart';
import 'package:runconnect/features/board/presentation/widgets/segmented_tab_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc()..add(BoardLoadRequested()),
      child: const _BoardView(),
    );
  }

  static BoardBloc _buildBloc() {
    final client = Supabase.instance.client;
    final dataSource = BoardRemoteDataSourceImpl(client);
    final repository = BoardRepositoryImpl(dataSource);
    return BoardBloc(getLeaderboard: GetLeaderboardUseCase(repository));
  }
}

class _BoardView extends StatelessWidget {
  const _BoardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceVariant,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        toolbarHeight: 64,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Leaderboard',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            _AudienceSelector(),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<BoardBloc>().add(BoardLoadRequested());
            await context
                .read<BoardBloc>()
                .stream
                .firstWhere((s) => !s.isLoading);
          },
          child: BlocBuilder<BoardBloc, BoardState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: _PeriodSelector()),
                    const SizedBox(height: 16),
                    if (state.errorMessage != null)
                      _ErrorBanner(message: state.errorMessage!)
                    else
                      _Body(state: state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final BoardState state;

  @override
  Widget build(BuildContext context) {
    final ranked = state.result.ranked;
    final viewerRow = state.result.viewerRow;
    final loading = state.isLoading && ranked.isEmpty;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final first = ranked.isNotEmpty ? ranked[0] : null;
    final second = ranked.length >= 2 ? ranked[1] : null;
    final third = ranked.length >= 3 ? ranked[2] : null;
    final rest = ranked.length > 3 ? ranked.sublist(3) : const <LeaderboardEntry>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PodiumCard(first: first, second: second, third: third),
        const SizedBox(height: 16),
        if (rest.isEmpty && viewerRow == null && first == null)
          const _EmptyHint(),
        for (var i = 0; i < rest.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          LeaderboardRow(entry: rest[i]),
        ],
        if (viewerRow != null) ...[
          if (rest.isNotEmpty) const SizedBox(height: 14),
          LeaderboardRow(entry: viewerRow),
        ],
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.directions_run,
            size: 36,
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          const Text(
            'No completed runs yet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<BoardBloc>().add(BoardLoadRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardState>(
      buildWhen: (a, b) => a.period != b.period,
      builder: (context, state) {
        return SegmentedTabBar<LeaderboardPeriod>(
          values: const [
            LeaderboardPeriod.week,
            LeaderboardPeriod.month,
            LeaderboardPeriod.year,
          ],
          labels: const ['Week', 'Month', 'Year'],
          selected: state.period,
          horizontalPadding: 28,
          onChanged: (v) => context.read<BoardBloc>().add(BoardPeriodChanged(v)),
        );
      },
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  const _AudienceSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardBloc, BoardState>(
      buildWhen: (a, b) => a.audience != b.audience,
      builder: (context, state) {
        return SegmentedTabBar<LeaderboardAudience>(
          values: const [
            LeaderboardAudience.everyone,
            LeaderboardAudience.friends,
          ],
          labels: const ['Everyone', 'Friends'],
          selected: state.audience,
          onChanged: (v) =>
              context.read<BoardBloc>().add(BoardAudienceChanged(v)),
          darkSelected: true,
        );
      },
    );
  }
}
