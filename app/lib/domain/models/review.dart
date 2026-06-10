/// An immutable user review of a place.
class Review {
  const Review({
    required this.id,
    required this.placeId,
    required this.authorName,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String placeId;
  final String authorName;
  final int rating; // 1..5 whole stars
  final String text;
  final DateTime createdAt;
}
