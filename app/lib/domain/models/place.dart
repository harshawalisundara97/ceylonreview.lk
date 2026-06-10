import 'category.dart';

/// An immutable place that can be reviewed.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.imageUrl,
    this.trending = false,
  });

  final String id;
  final String name;
  final PlaceCategory category;
  final String district;
  final double latitude;
  final double longitude;

  /// Average rating, displayed with one decimal (e.g. 4.7).
  final double rating;
  final int reviewCount;
  final String description;
  final String imageUrl;
  final bool trending;

  /// `4.7` — one decimal, never `4.70`.
  String get ratingLabel => rating.toStringAsFixed(1);

  /// `1.2k` instead of `1,200`, per the design system.
  String get reviewCountLabel {
    if (reviewCount < 1000) return '$reviewCount';
    final k = reviewCount / 1000;
    return '${k.toStringAsFixed(k < 10 ? 1 : 0)}k';
  }
}
