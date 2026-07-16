import 'package:latlong2/latlong.dart';

/// Turns a free-text place name into map coordinates.
abstract interface class GeocodingRepository {
  /// Returns the best-match coordinates for [query], or null if nothing was
  /// found or the request failed.
  Future<LatLng?> search(String query);
}
