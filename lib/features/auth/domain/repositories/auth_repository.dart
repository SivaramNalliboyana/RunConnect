abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signOut();
  bool get isAuthenticated;
}
