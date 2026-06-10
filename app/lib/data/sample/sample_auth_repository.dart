import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Mock auth: any non-empty credentials sign in. The display name is
/// derived from the email's local part.
class SampleAuthRepository implements AuthRepository {
  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password are required.');
    }
    // Brief delay so the UI's loading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final local = email.split('@').first;
    final name = local
        .split(RegExp(r'[._\-]+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
    return AppUser(name: name.isEmpty ? 'Traveller' : name, email: email);
  }

  @override
  Future<void> signOut() async {}
}
