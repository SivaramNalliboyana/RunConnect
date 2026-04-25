import 'package:image_picker/image_picker.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class AuthRemoteDataSource {
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure("Unknown error occured");
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
      String avatarUrl =
          "https://upload.wikimedia.org/wikipedia/commons/0/03/Twitter_default_profile_400x400.png";

      if (image != null) {
        try {
          final bytes = await image.readAsBytes();
          final ext = image.path.split('.').last;
          final uid = const Uuid().v4();
          final sanitizedName = name.trim().toLowerCase().replaceAll(' ', '_');
          final tempPath = '${sanitizedName}_$uid.$ext';

          await _client.storage.from('avatars').uploadBinary(
            tempPath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

          avatarUrl = _client.storage.from('avatars').getPublicUrl(tempPath);
        } on StorageException catch (e) {
          throw AuthFailure('Failed to upload image: ${e.message}');
        }
      }

      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'avatar_url': avatarUrl},
      );
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Unknown error occurred');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure("Unknown error occured");
    }
  }

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;
}
