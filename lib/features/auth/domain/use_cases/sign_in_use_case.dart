import 'package:runconnect/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  SignInUseCase(this._repository);

  Future<void> call(String email, String password) {
    if (email.trim().isEmpty) throw const AuthFailure('Email cannot be empty');
    if (!email.contains('@')) throw const AuthFailure('Enter a valid email');
    if (password.isEmpty) throw const AuthFailure('Password cannot be empty');

    return _repository.signInWithEmail(email, password);
  }
}
