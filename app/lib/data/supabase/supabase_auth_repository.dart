import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart'
    show SupabaseClient, User;

import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Real authentication via Supabase Auth (email + password). Sessions are
/// persisted on-device by the SDK and restored on app start.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AppUser? get currentUser => _toAppUser(_client.auth.currentUser);

  @override
  Future<AppUser> signIn(
      {required String email, required String password}) async {
    try {
      final res = await _client.auth
          .signInWithPassword(email: email.trim(), password: password);
      final user = _toAppUser(res.user);
      if (user == null) throw const AuthFailure('Sign in failed.');
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      // If email confirmation is enabled, there is no session yet — the
      // caller shows a "confirm your email" message in that case.
      if (res.session == null) {
        throw const EmailConfirmationRequired();
      }
      final user = _toAppUser(res.user);
      if (user == null) throw const AuthFailure('Sign up failed.');
      return user;
    } on supabase.AuthException catch (e) {
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final name = (user.userMetadata?['name'] as String?)?.trim();
    return AppUser(
      id: user.id,
      name: (name == null || name.isEmpty) ? email.split('@').first : name,
      email: email,
    );
  }

  String _friendlyMessage(supabase.AuthException e) => switch (e.code) {
        'invalid_credentials' => 'Incorrect email or password.',
        'user_already_exists' ||
        'email_exists' =>
          'An account with this email already exists.',
        'weak_password' => 'Password is too weak — use at least 6 characters.',
        'email_address_invalid' => 'Please enter a valid email address.',
        'over_request_rate_limit' =>
          'Too many attempts. Please wait a moment and try again.',
        _ => e.message,
      };
}
