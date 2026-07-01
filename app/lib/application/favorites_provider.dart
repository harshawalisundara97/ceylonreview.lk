import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'repository_providers.dart';

class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return const <String>{};
    return ref.watch(favoritesRepositoryProvider).fetchMyFavoriteIds();
  }

  /// Adds or removes [placeId], updating local state immediately and
  /// reverting if the backing repository call fails.
  Future<void> toggle(String placeId) async {
    final current = state.valueOrNull ?? const <String>{};
    final wasFavorite = current.contains(placeId);
    final optimistic = {...current};
    wasFavorite ? optimistic.remove(placeId) : optimistic.add(placeId);
    state = AsyncData(optimistic);

    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (wasFavorite) {
        await repo.remove(placeId);
      } else {
        await repo.add(placeId);
      }
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final myFavoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(
        FavoriteIdsNotifier.new);
