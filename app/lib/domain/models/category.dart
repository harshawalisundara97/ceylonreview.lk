/// The six place categories of Ceylon Review, plus [home] for the
/// default brand context (no category selected).
enum PlaceCategory {
  home,
  food,
  nature,
  beach,
  hotels,
  temples,
  shopping;

  /// ALL-CAPS label used in chips and overlines, per the design system.
  String get label => switch (this) {
        home => 'ALL',
        food => 'FOOD',
        nature => 'NATURE',
        beach => 'BEACHES',
        hotels => 'HOTELS',
        temples => 'TEMPLES',
        shopping => 'SHOPPING',
      };

  /// Title-case display name for headings.
  String get displayName => switch (this) {
        home => 'All Places',
        food => 'Food',
        nature => 'Nature',
        beach => 'Beaches',
        hotels => 'Hotels',
        temples => 'Temples',
        shopping => 'Shopping',
      };

  /// The six selectable categories (excludes [home]).
  static List<PlaceCategory> get selectable =>
      values.where((c) => c != home).toList();
}
