import '../../domain/models/review.dart';
import '../../domain/repositories/reviews_repository.dart';
import 'sample_data.dart';

/// In-memory implementation: seeded with [SampleData.reviews]; new reviews
/// persist for the session.
class SampleReviewsRepository implements ReviewsRepository {
  SampleReviewsRepository({List<Review>? seed})
      : _reviews = [...(seed ?? SampleData.reviews)];

  final List<Review> _reviews;
  final List<Review> _mine = [];
  int _nextId = 1000;

  @override
  Future<List<Review>> fetchForPlace(String placeId) async {
    final list = _reviews.where((r) => r.placeId == placeId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<Review>> fetchMine() async {
    final list = [..._mine]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
  }) async {
    final review = Review(
      id: 'r${_nextId++}',
      placeId: placeId,
      authorName: authorName,
      rating: rating,
      text: text,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    _mine.add(review);
    return review;
  }
}
