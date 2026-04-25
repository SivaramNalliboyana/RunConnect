import 'package:image_picker/image_picker.dart';
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
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    XFile? image,
  ) async {
    String avatarUrl =
        "https://upload.wikimedia.org/wikipedia/commons/0/03/Twitter_default_profile_400x400.png";

    if (image != null) {
      final bytes = await image.readAsBytes();
      final ext = image.path.split('.').last;
      final uid = const Uuid().v4();
      final sanitizedName = name.trim().toLowerCase().replaceAll(' ', '_');
      final tempPath = '${sanitizedName}_$uid.$ext';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            tempPath,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext'),
          );

      avatarUrl = _client.storage.from('avatars').getPublicUrl(tempPath);
    }

    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'avatar_url': avatarUrl},
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;
}
