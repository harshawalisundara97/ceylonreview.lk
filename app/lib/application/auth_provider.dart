import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user.dart';
import 'repository_providers.dart';

/// Session state: null = signed out. Restores a persisted session on start.
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.read(authRepositoryProvider).currentUser;

  Future<void> signIn({required String email, required String password}) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
    state = user;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await ref
        .read(authRepositoryProvider)
        .signUp(name: name, email: email, password: password);
    state = user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);
