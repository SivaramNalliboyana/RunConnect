import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/board/domain/entities/leaderboard_entry.dart';
import 'package:runconnect/features/board/presentation/bloc/board_bloc.dart';
import 'package:runconnect/features/board/presentation/bloc/board_event.dart';
import 'package:runconnect/features/board/presentation/bloc/board_state.dart';
import 'package:runconnect/features/board/presentation/widgets/leaderboard_row.dart';
import 'package:runconnect/features/board/presentation/widgets/podium_card.dart';
import 'package:runconnect/features/board/presentation/widgets/segmented_tab_bar.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  static const _topThree = <LeaderboardEntry>[
    LeaderboardEntry(
      id: '1',
      rank: 1,
      displayName: 'Sarah J.',
      distanceKm: 62.5,
      runsCount: 8,
    ),
    LeaderboardEntry(
      id: '2',
      rank: 2,
      displayName: 'Marcus V.',
      distanceKm: 48.2,
      runsCount: 6,
    ),
    LeaderboardEntry(
      id: '3',
      rank: 3,
      displayName: 'David K.',
      distanceKm: 42.1,
      runsCount: 6,
    ),
  ];

  static const _restOfList = <LeaderboardEntry>[
    LeaderboardEntry(
      id: '4',
      rank: 4,
      displayName: 'Elena Ross',
      distanceKm: 38.9,
      runsCount: 5,
    ),
    LeaderboardEntry(
      id: '5',
      rank: 5,
      displayName: 'Tom Chen',
      distanceKm: 35.4,
      runsCount: 3,
    ),
    LeaderboardEntry(
      id: 'me',
      rank: 12,
      displayName: 'You (Alex)',
      distanceKm: 22.1,
      runsCount: 2,
      isCurrentUser: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardBloc(),
      child: const _BoardView(topThree: _topThree, restOfList: _restOfList),
    );
  }
}

class _BoardView extends StatelessWidget {
  const _BoardView({required this.topThree, required this.restOfList});

  final List<LeaderboardEntry> topThree;
  final List<LeaderboardEntry> restOfList;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: _PeriodSelector()),
              const SizedBox(height: 16),
              PodiumCard(
                first: topThree[0],
                second: topThree[1],
                third: topThree[2],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < restOfList.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                LeaderboardRow(entry: restOfList[i]),
              ],
            ],
          ),
        ),
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
