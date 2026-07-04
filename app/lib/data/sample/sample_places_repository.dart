import '../../domain/models/category.dart';
import '../../domain/models/place.dart';
import '../../domain/repositories/places_repository.dart';
import 'sample_data.dart';

/// In-memory implementation backed by [SampleData].
class SamplePlacesRepository implements PlacesRepository {
  SamplePlacesRepository({List<Place>? places})
      : _places = [...(places ?? SampleData.places)];

  final List<Place> _places;

  @override
  Future<List<Place>> fetchAll() async => List.unmodifiable(_places);

  @override
  Future<List<Place>> fetchByCategory(PlaceCategory category) async {
    if (category == PlaceCategory.home) return fetchAll();
    return _places.where((p) => p.category == category).toList();
  }

  @override
  Future<List<Place>> fetchTrending() async =>
      _places.where((p) => p.trending).toList();

  @override
  Future<Place?> fetchById(String id) async {
    for (final p in _places) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<List<Place>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _places
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.district.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<Place> addPlace(Place place) async {
    _places.add(place);
    return place;
  }
}
