import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/review.dart';
import 'auth_provider.dart';
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
  }) async {
    final user = _ref.read(authProvider);
    await _ref.read(reviewsRepositoryProvider).add(
          placeId: placeId,
          authorName: user?.name ?? 'Traveller',
          rating: rating,
          text: text,
        );
    _ref.invalidate(reviewsForPlaceProvider(placeId));
    _ref.invalidate(myReviewsProvider);
    // The backend recomputes the place's rating/review count on insert.
    _ref.invalidate(placeByIdProvider(placeId));
    _ref.invalidate(allPlacesProvider);
    _ref.invalidate(trendingPlacesProvider);
    _ref.invalidate(placesByCategoryProvider);
  }
}

final reviewSubmitterProvider = Provider((ref) => ReviewSubmitter(ref));
