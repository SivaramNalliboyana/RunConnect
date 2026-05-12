import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/board/domain/use_cases/get_leaderboard_use_case.dart';
import 'board_event.dart';
import 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final GetLeaderboardUseCase _getLeaderboard;

  BoardBloc({required GetLeaderboardUseCase getLeaderboard})
    : _getLeaderboard = getLeaderboard,
      super(const BoardState()) {
    on<BoardLoadRequested>(_onLoad);
    on<BoardPeriodChanged>(_onPeriodChanged);
    on<BoardAudienceChanged>(_onAudienceChanged);
  }

  Future<void> _onLoad(
    BoardLoadRequested event,
    Emitter<BoardState> emit,
  ) async {
    await _fetch(state.period, state.audience, emit);
  }

  Future<void> _onPeriodChanged(
    BoardPeriodChanged event,
    Emitter<BoardState> emit,
  ) async {
    emit(state.copyWith(period: event.period));
    await _fetch(event.period, state.audience, emit);
  }

  Future<void> _onAudienceChanged(
    BoardAudienceChanged event,
    Emitter<BoardState> emit,
  ) async {
    emit(state.copyWith(audience: event.audience));
    await _fetch(state.period, event.audience, emit);
  }

  Future<void> _fetch(
    LeaderboardPeriod period,
    LeaderboardAudience audience,
    Emitter<BoardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _getLeaderboard(
        window: period.name,
        audience: audience.name,
      );
      emit(state.copyWith(isLoading: false, result: result));
    } on Failure catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
