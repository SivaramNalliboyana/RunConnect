import 'board_state.dart';

abstract class BoardEvent {}

class BoardPeriodChanged extends BoardEvent {
  BoardPeriodChanged(this.period);
  final LeaderboardPeriod period;
}

class BoardAudienceChanged extends BoardEvent {
  BoardAudienceChanged(this.audience);
  final LeaderboardAudience audience;
}
