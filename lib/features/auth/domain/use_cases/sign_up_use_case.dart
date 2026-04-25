import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<void> call(String email, String password) =>
      _repository.signUpWithEmail(email, password);
}
