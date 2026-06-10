import '../models/review.dart';

/// Read/write access to reviews for places.
abstract interface class ReviewsRepository {
  Future<List<Review>> fetchForPlace(String placeId);

  Future<List<Review>> fetchByAuthor(String authorName);

  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
  });
}
