import '../models/user.dart';

/// Authentication. The sample implementation accepts any non-empty
/// credentials; the Supabase implementation does real email + password auth.
abstract interface class AuthRepository {
  /// The user restored from a persisted session, or null if signed out.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Sends a password-reset email to [email]. Never reveals whether the
  /// address has an account — the UI should show one generic confirmation
  /// message regardless.
  Future<void> sendPasswordResetEmail(String email);
}

/// Auth error with a message safe to show directly in the UI.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sign-up succeeded but the account needs email confirmation before the
/// first sign-in (depends on the backend's auth settings).
class EmailConfirmationRequired implements Exception {
  const EmailConfirmationRequired();
}
