/// The signed-in user.
class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  /// The auth user id (Supabase `auth.users.id`).
  final String id;
  final String name;
  final String email;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
