import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_event.dart';
import 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  BoardBloc() : super(const BoardState()) {
    on<BoardPeriodChanged>(
      (event, emit) => emit(state.copyWith(period: event.period)),
    );
    on<BoardAudienceChanged>(
      (event, emit) => emit(state.copyWith(audience: event.audience)),
    );
  }
}
