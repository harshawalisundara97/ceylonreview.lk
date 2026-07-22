/// An immutable user review of a place.
class Review {
  const Review({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.authorName,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.photoUrls = const [],
  });

  final String id;
  final String placeId;

  /// The reviewer's user id (`profiles.id` / `auth.users.id`).
  final String authorId;
  final String authorName;
  final int rating; // 1..5 whole stars
  final String text;
  final DateTime createdAt;

  /// Public URLs of photos the reviewer attached (0–3).
  final List<String> photoUrls;
}
