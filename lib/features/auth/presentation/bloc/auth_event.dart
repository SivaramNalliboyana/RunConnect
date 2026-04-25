import 'package:image_picker/image_picker.dart';

abstract class AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  AuthSignUpRequested(this.email, this.password, this.name);
}

class AuthSignOutRequested extends AuthEvent {}

class AuthProfileImagePicked extends AuthEvent {
  final XFile image;
  AuthProfileImagePicked(this.image);
}
