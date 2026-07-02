import '../../domain/repositories/favorites_repository.dart';

/// In-memory implementation: starts empty; favorites persist for the session.
class SampleFavoritesRepository implements FavoritesRepository {
  final Set<String> _favoriteIds = {};

  @override
  Future<Set<String>> fetchMyFavoriteIds() async => {..._favoriteIds};

  @override
  Future<void> add(String placeId) async => _favoriteIds.add(placeId);

  @override
  Future<void> remove(String placeId) async => _favoriteIds.remove(placeId);
}
