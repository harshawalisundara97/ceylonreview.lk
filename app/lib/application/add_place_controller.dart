import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/category.dart';
import '../domain/models/place.dart';
import 'auth_provider.dart';
import 'places_provider.dart';
import 'repository_providers.dart';

/// Submits a new community place: uploads the photo (if any), inserts the
/// place, and refreshes place lists so it appears everywhere immediately.
class AddPlaceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Place> submit({
    required String name,
    required PlaceCategory category,
    required String district,
    required String description,
    required double latitude,
    required double longitude,
    int? priceLevel,
    String? opensAt,
    String? closesAt,
    Uint8List? photoBytes,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authProvider);
      if (user == null) {
        throw StateError('You must be signed in to add a place.');
      }
      final id = const Uuid().v4();
      var imageUrl = '';
      if (photoBytes != null) {
        imageUrl = await ref
            .read(photoStorageRepositoryProvider)
            .uploadPhoto(photoBytes, fileName: '${user.id}/$id.jpg');
      }
      late final Place created;
      try {
        created = await ref.read(placesRepositoryProvider).addPlace(Place(
              id: id,
              name: name,
              category: category,
              district: district,
              latitude: latitude,
              longitude: longitude,
              rating: 0,
              reviewCount: 0,
              description: description,
              imageUrl: imageUrl,
              priceLevel: priceLevel,
              opensAt: opensAt,
              closesAt: closesAt,
              addedBy: user.id,
            ));
      } catch (_) {
        if (imageUrl.isNotEmpty) {
          // Best-effort cleanup: don't let a failed delete mask the real error.
          await ref
              .read(photoStorageRepositoryProvider)
              .deletePhoto(imageUrl)
              .catchError((_) {});
        }
        rethrow;
      }
      ref.invalidate(allPlacesProvider);
      ref.invalidate(trendingPlacesProvider);
      ref.invalidate(placesByCategoryProvider);
      ref.invalidate(placeSearchProvider);
      state = const AsyncData(null);
      return created;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final addPlaceControllerProvider =
    AsyncNotifierProvider<AddPlaceController, void>(AddPlaceController.new);
