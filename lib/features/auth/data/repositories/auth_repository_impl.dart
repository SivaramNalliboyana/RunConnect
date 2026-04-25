import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:runconnect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _dataSource.signInWithEmail(email, password);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    XFile? image,
  ) async {
    try {
      await _dataSource.signUpWithEmail(email, password, name, image);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  bool get isAuthenticated => _dataSource.isAuthenticated;
}
