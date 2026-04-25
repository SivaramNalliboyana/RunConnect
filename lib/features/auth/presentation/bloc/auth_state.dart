abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthFailureState extends AuthState {
  final String message;
  AuthFailureState(this.message);
}

class AuthImageSelected extends AuthState {
  final String imagePath;
  AuthImageSelected(this.imagePath);
}
