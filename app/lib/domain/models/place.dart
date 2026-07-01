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
    this.priceLevel,
    this.opensAt,
    this.closesAt,
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

  /// 1–3 (₨/₨₨/₨₨₨). Null where price doesn't apply (temples, nature, beach).
  final int? priceLevel;

  /// Daily opening/closing time as `"HH:mm"`. Null where hours don't apply.
  final String? opensAt;
  final String? closesAt;

  /// Whether the place is open right now, given [opensAt]/[closesAt].
  /// Returns null if hours aren't set for this place.
  bool? get isOpenNow {
    if (opensAt == null || closesAt == null) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = _minutesSinceMidnight(opensAt!);
    final closeMinutes = _minutesSinceMidnight(closesAt!);
    if (closeMinutes <= openMinutes) {
      // Overnight hours (e.g. 18:00–02:00).
      return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
    }
    return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
  }

  static int _minutesSinceMidnight(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// `4.7` — one decimal, never `4.70`.
  String get ratingLabel => rating.toStringAsFixed(1);

  /// `1.2k` instead of `1,200`, per the design system.
  String get reviewCountLabel {
    if (reviewCount < 1000) return '$reviewCount';
    final k = reviewCount / 1000;
    return '${k.toStringAsFixed(k < 10 ? 1 : 0)}k';
  }
}
