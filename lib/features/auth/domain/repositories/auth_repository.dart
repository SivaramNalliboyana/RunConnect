import 'package:image_picker/image_picker.dart';

abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    XFile? image,
  );
  Future<void> signOut();
  bool get isAuthenticated;
}
