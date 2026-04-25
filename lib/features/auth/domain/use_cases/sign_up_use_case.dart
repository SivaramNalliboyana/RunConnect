import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  SignUpUseCase(this._repository);

  Future<void> call(String email, String password, String name, XFile? image) {
    if (name.trim().isEmpty) throw const AuthFailure('Name cannot be empty');
    if (email.trim().isEmpty) throw const AuthFailure('Email cannot be empty');
    if (!email.contains('@')) throw const AuthFailure('Enter a valid email');
    if (password.length < 6)
      throw const AuthFailure('Password must be at least 6 characters');
    if (image == null) throw const AuthFailure("Image of you must be uploaded");

    return _repository.signUpWithEmail(email, password, name, image);
  }
}
