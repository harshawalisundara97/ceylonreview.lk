import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/review.dart';
import 'auth_provider.dart';
import 'leaderboard_provider.dart';
import 'places_provider.dart';
import 'repository_providers.dart';

final reviewsForPlaceProvider = FutureProvider.family<List<Review>, String>(
    (ref, placeId) =>
        ref.watch(reviewsRepositoryProvider).fetchForPlace(placeId));

final myReviewsProvider = FutureProvider<List<Review>>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Future.value(const <Review>[]);
  return ref.watch(reviewsRepositoryProvider).fetchMine();
});

/// Posts a review and refreshes the affected lists.
class ReviewSubmitter {
  ReviewSubmitter(this._ref);

  final Ref _ref;

  Future<void> submit({
    required String placeId,
    required int rating,
    required String text,
    List<Uint8List> photoBytes = const [],
  }) async {
    final user = _ref.read(authProvider);
    if (photoBytes.isNotEmpty && user == null) {
      throw StateError('You must be signed in to add photos to a review.');
    }
    final batchId = const Uuid().v4();
    final uploadedUrls = <String>[];
    try {
      for (var i = 0; i < photoBytes.length; i++) {
        final url = await _ref.read(photoStorageRepositoryProvider).uploadPhoto(
              photoBytes[i],
              fileName: '${user!.id}/$batchId-$i.jpg',
            );
        uploadedUrls.add(url);
      }
      await _ref.read(reviewsRepositoryProvider).add(
            placeId: placeId,
            authorName: user?.name ?? 'Traveller',
            rating: rating,
            text: text,
            photoUrls: uploadedUrls,
          );
    } catch (_) {
      for (final url in uploadedUrls) {
        await _ref
            .read(photoStorageRepositoryProvider)
            .deletePhoto(url)
            .catchError((_) {});
      }
      rethrow;
    }
    _ref.invalidate(reviewsForPlaceProvider(placeId));
    _ref.invalidate(myReviewsProvider);
    // The backend recomputes the place's rating/review count on insert.
    _ref.invalidate(placeByIdProvider(placeId));
    _ref.invalidate(allPlacesProvider);
    _ref.invalidate(trendingPlacesProvider);
    _ref.invalidate(placesByCategoryProvider);
    // The backend also recomputes the reviewer's points via a trigger.
    _ref.invalidate(leaderboardProvider);
    _ref.invalidate(myRankProvider);
  }
}

final reviewSubmitterProvider = Provider((ref) => ReviewSubmitter(ref));
