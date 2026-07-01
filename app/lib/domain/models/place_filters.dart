/// How to order a filtered place list.
enum PlaceSort {
  rating,
  distance,
  price;

  String get label => switch (this) {
        rating => 'Rating',
        distance => 'Distance',
        price => 'Price',
      };
}

/// Filter/sort selections applied on top of an already-fetched place list.
class PlaceFilters {
  const PlaceFilters({
    this.priceLevel,
    this.openNowOnly = false,
    this.sortBy = PlaceSort.rating,
  });

  /// 1–3 (₨/₨₨/₨₨₨), or null for "any price".
  final int? priceLevel;
  final bool openNowOnly;
  final PlaceSort sortBy;

  bool get isActive => priceLevel != null || openNowOnly;

  PlaceFilters copyWith({
    int? priceLevel,
    bool clearPriceLevel = false,
    bool? openNowOnly,
    PlaceSort? sortBy,
  }) =>
      PlaceFilters(
        priceLevel: clearPriceLevel ? null : (priceLevel ?? this.priceLevel),
        openNowOnly: openNowOnly ?? this.openNowOnly,
        sortBy: sortBy ?? this.sortBy,
      );
}
