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
    );
