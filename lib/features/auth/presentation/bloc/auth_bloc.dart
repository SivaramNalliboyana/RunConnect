import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:runconnect/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;

  AuthBloc({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
  })  : _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signIn(event.email, event.password);
      emit(AuthAuthenticated());
    } on AuthFailure catch (e) {
      emit(AuthFailureState(e.message));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signUp(event.email, event.password);
      emit(AuthAuthenticated());
    } on AuthFailure catch (e) {
      emit(AuthFailureState(e.message));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signOut();
      emit(AuthUnauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthFailureState(e.message));
    }
  }
}
