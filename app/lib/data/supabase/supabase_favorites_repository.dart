import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/favorites_repository.dart';

/// Favorites backed by the Supabase `favorites` table (RLS-scoped to the
/// signed-in user).
class SupabaseFavoritesRepository implements FavoritesRepository {
  SupabaseFavoritesRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Set<String>> fetchMyFavoriteIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};
    final rows =
        await _client.from('favorites').select('place_id').eq('user_id', userId);
    return rows.map((row) => row['place_id'] as String).toSet();
  }

  @override
  Future<void> add(String placeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save favorites.');
    }
    await _client
        .from('favorites')
        .insert({'user_id': userId, 'place_id': placeId});
  }

  @override
  Future<void> remove(String placeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('place_id', placeId);
  }
}
