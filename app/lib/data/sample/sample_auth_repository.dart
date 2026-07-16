import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Mock auth: any non-empty credentials sign in. The display name is
/// derived from the email's local part. No session persistence.
class SampleAuthRepository implements AuthRepository {
  @override
  AppUser? get currentUser => null;

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthFailure('Email and password are required.');
    }
    // Brief delay so the UI's loading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final local = email.split('@').first;
    final name = local
        .split(RegExp(r'[._\-]+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
    return AppUser(id: 'sample-user', name: name.isEmpty ? 'Traveller' : name, email: email);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      throw const AuthFailure('Name is required.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return AppUser(id: 'sample-user', name: name.trim(), email: email);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}
}
