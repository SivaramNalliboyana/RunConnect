import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfile;
  final String _userId;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfile,
    required String userId,
  }) : _getUserProfile = getUserProfile,
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
      final profile = await _getUserProfile(_userId);
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
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
