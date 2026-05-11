import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/entities/profile_event_item.dart';
import 'package:runconnect/features/profile/domain/entities/user_profile.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_my_events_use_case.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfile;
  final GetMyEventsUseCase _getMyEvents;
  final String _userId;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfile,
    required GetMyEventsUseCase getMyEvents,
    required String userId,
  }) : _getUserProfile = getUserProfile,
       _getMyEvents = getMyEvents,
       _userId = userId,
       super(const ProfileState.initial()) {
    on<ProfileRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait([
        _getUserProfile(_userId),
        _getMyEvents(_userId),
      ]);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: results[0] as UserProfile,
          myEvents: results[1] as MyEventsBucket,
        ),
      );
    } on Failure catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
