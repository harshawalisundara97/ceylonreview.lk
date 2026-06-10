/// Spacing, radius, and motion tokens from `tokens/spacing.css`.
abstract final class AppSpacing {
  // 8px base grid with 4px half-steps.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Screen edge gutter.
  static const double gutter = 16;

  /// Minimum tap target.
  static const double minTap = 44;
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

abstract final class AppMotion {
  /// Category color cross-fade — the signature interaction.
  static const slow = Duration(milliseconds: 360);

  /// Card entrances.
  static const medium = Duration(milliseconds: 220);

  /// Button press feedback.
  static const fast = Duration(milliseconds: 120);

  /// Stagger per list item on entrance.
  static const stagger = Duration(milliseconds: 40);
}
