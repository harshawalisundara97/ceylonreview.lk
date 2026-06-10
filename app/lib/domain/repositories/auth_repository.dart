import '../models/user.dart';

/// Authentication. The sample implementation accepts any non-empty
/// credentials; a real backend implementation can replace it unchanged.
abstract interface class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});

  Future<void> signOut();
}
