import '../models/category.dart';
import '../models/place.dart';

/// Read access to places. Screens depend on this interface only;
/// implementations (sample now, Supabase later) are injected via Riverpod.
abstract interface class PlacesRepository {
  Future<List<Place>> fetchAll();

  Future<List<Place>> fetchByCategory(PlaceCategory category);

  Future<List<Place>> fetchTrending();

  Future<Place?> fetchById(String id);

  Future<List<Place>> search(String query);

  /// Adds a community place and returns it as stored.
  Future<Place> addPlace(Place place);
}
