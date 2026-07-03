import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/category.dart';
import '../../domain/models/place.dart';
import '../../domain/repositories/places_repository.dart';

/// Places backed by the Supabase `places` table.
class SupabasePlacesRepository implements PlacesRepository {
  SupabasePlacesRepository(this._client);

  final SupabaseClient _client;

  PostgrestFilterBuilder<List<Map<String, dynamic>>> get _select =>
      _client.from('places').select();

  @override
  Future<List<Place>> fetchAll() async =>
      (await _select.order('name', ascending: true)).map(_placeFromRow).toList();

  @override
  Future<List<Place>> fetchByCategory(PlaceCategory category) async {
    if (category == PlaceCategory.home) return fetchAll();
    final rows = await _select
        .eq('category', category.name)
        .order('rating', ascending: false);
    return rows.map(_placeFromRow).toList();
  }

  @override
  Future<List<Place>> fetchTrending() async {
    final rows =
        await _select.eq('trending', true).order('rating', ascending: false);
    return rows.map(_placeFromRow).toList();
  }

  @override
  Future<Place?> fetchById(String id) async {
    final row = await _select.eq('id', id).maybeSingle();
    return row == null ? null : _placeFromRow(row);
  }

  @override
  Future<List<Place>> search(String query) async {
    final q = query.trim().replaceAll(RegExp(r'[%,()]'), ' ');
    if (q.isEmpty) return [];
    final rows = await _select
        .or('name.ilike.%$q%,district.ilike.%$q%')
        .order('rating', ascending: false);
    return rows.map(_placeFromRow).toList();
  }

  @override
  Future<Place> addPlace(Place place) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to add a place.');
    }
    final row = await _client
        .from('places')
        .insert({
          'id': place.id,
          'name': place.name,
          'category': place.category.name,
          'district': place.district,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'rating': 0,
          'review_count': 0,
          'description': place.description,
          'image_url': place.imageUrl,
          'trending': false,
          'price_level': place.priceLevel,
          'opens_at': place.opensAt,
          'closes_at': place.closesAt,
          'added_by': userId,
        })
        .select()
        .single();
    return _placeFromRow(row);
  }
}

Place _placeFromRow(Map<String, dynamic> row) => Place(
      id: row['id'] as String,
      name: row['name'] as String,
      category: PlaceCategory.values.byName(row['category'] as String),
      district: row['district'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      rating: (row['rating'] as num).toDouble(),
      reviewCount: row['review_count'] as int,
      description: row['description'] as String,
      imageUrl: row['image_url'] as String,
      trending: row['trending'] as bool,
      priceLevel: row['price_level'] as int?,
      opensAt: row['opens_at'] as String?,
      closesAt: row['closes_at'] as String?,
      addedBy: row['added_by'] as String?,
    );
