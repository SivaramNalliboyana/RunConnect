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
    } on AuthFailure {
      rethrow;
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
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

}
