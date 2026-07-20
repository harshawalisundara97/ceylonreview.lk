import '../../core/l10n_ext.dart';
import '../../domain/models/category.dart';

/// UI-layer localized names for [PlaceCategory]. The domain enum's English
/// getters remain for non-UI uses; widgets use these instead.
extension PlaceCategoryLabels on PlaceCategory {
  String localizedDisplayName(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryAllPlaces,
        PlaceCategory.food => l10n.categoryFood,
        PlaceCategory.nature => l10n.categoryNature,
        PlaceCategory.beach => l10n.categoryBeaches,
        PlaceCategory.hotels => l10n.categoryHotels,
        PlaceCategory.temples => l10n.categoryTemples,
        PlaceCategory.shopping => l10n.categoryShopping,
      };

  /// ALL-CAPS chip/overline style (no-op for Sinhala/Tamil scripts).
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryAll.toUpperCase(),
        _ => localizedDisplayName(l10n).toUpperCase(),
      };
}
