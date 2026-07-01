import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// The device's current position, fetched once per session (or refreshed via
/// [refresh], e.g. on pull-to-refresh). Not continuously tracked.
///
/// Resolves to `null` if location services are disabled or permission is
/// denied — the UI should treat that as "distance features unavailable"
/// rather than an error.
class LocationNotifier extends AsyncNotifier<Position?> {
  @override
  Future<Position?> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Position?> _fetch() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, Position?>(LocationNotifier.new);
