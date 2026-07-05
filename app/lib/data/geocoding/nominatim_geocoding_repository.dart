import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../domain/repositories/geocoding_repository.dart';

/// Free-text search via the OpenStreetMap Nominatim public API, biased to
/// Sri Lanka. No API key; requests must fire no more than once per second
/// and carry a descriptive User-Agent per Nominatim's usage policy.
class NominatimGeocodingRepository implements GeocodingRepository {
  @override
  Future<LatLng?> search(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'lk',
    });
    final response = await http.get(uri, headers: {
      'User-Agent': 'CeylonReviewApp/1.0 (contact: harshawalisundara8@gmail.com)',
    });
    if (response.statusCode != 200) return null;

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    final lat = double.tryParse(first['lat'] as String);
    final lon = double.tryParse(first['lon'] as String);
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }
}
