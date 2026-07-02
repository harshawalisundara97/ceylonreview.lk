/// Read/write access to the signed-in user's favorited places.
abstract interface class FavoritesRepository {
  /// The place ids the current user has favorited.
  Future<Set<String>> fetchMyFavoriteIds();

  Future<void> add(String placeId);

  Future<void> remove(String placeId);
}
