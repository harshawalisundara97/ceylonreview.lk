import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../domain/models/category.dart';
import '../domain/models/place.dart';
import '../domain/models/place_filters.dart';
import 'location_provider.dart';
import 'places_provider.dart';

class PlaceFiltersNotifier extends Notifier<PlaceFilters> {
  @override
  PlaceFilters build() => const PlaceFilters();

  void setPriceLevel(int? level) => state = level == null
      ? state.copyWith(clearPriceLevel: true)
      : state.copyWith(priceLevel: level);

  void setOpenNowOnly(bool value) => state = state.copyWith(openNowOnly: value);

  void setSortBy(PlaceSort sort) => state = state.copyWith(sortBy: sort);

  void reset() => state = const PlaceFilters();
}

final placeFiltersProvider =
    NotifierProvider<PlaceFiltersNotifier, PlaceFilters>(
        PlaceFiltersNotifier.new);

const _distance = latlong.Distance();

/// Straight-line distance in kilometres from the device's current position
/// to [place], or null if location isn't available.
double? distanceToPlaceKm(latlong.LatLng? from, Place place) {
  if (from == null) return null;
  return _distance.as(
        latlong.LengthUnit.Kilometer,
        from,
        latlong.LatLng(place.latitude, place.longitude),
      );
}

/// Places for [category] with the current [placeFiltersProvider] selections
/// applied (price, open-now, sort — including distance sort using the
/// device's current location when available).
final filteredPlacesProvider =
    FutureProvider.family<List<Place>, PlaceCategory>((ref, category) async {
  final places = await ref.watch(placesByCategoryProvider(category).future);
  final filters = ref.watch(placeFiltersProvider);
  final position = ref.watch(locationProvider).valueOrNull;
  final from =
      position == null ? null : latlong.LatLng(position.latitude, position.longitude);

  var result = places.where((place) {
    if (filters.priceLevel != null && place.priceLevel != filters.priceLevel) {
      return false;
    }
    if (filters.openNowOnly && place.isOpenNow != true) return false;
    return true;
  }).toList();

  switch (filters.sortBy) {
    case PlaceSort.rating:
      result.sort((a, b) => b.rating.compareTo(a.rating));
    case PlaceSort.price:
      result.sort((a, b) => (a.priceLevel ?? 99).compareTo(b.priceLevel ?? 99));
    case PlaceSort.distance:
      if (from != null) {
        result.sort((a, b) => distanceToPlaceKm(from, a)!
            .compareTo(distanceToPlaceKm(from, b)!));
      }
  }

  return result;
});
