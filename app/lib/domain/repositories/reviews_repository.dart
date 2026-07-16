import '../models/review.dart';

/// Read/write access to reviews for places.
abstract interface class ReviewsRepository {
  Future<List<Review>> fetchForPlace(String placeId);

  /// Reviews written by the signed-in user, newest first.
  Future<List<Review>> fetchMine();

  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
    List<String> photoUrls = const [],
  });
}
