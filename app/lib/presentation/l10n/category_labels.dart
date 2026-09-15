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

  String localizedBlurb(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryBlurbAll,
        PlaceCategory.food => l10n.categoryBlurbFood,
        PlaceCategory.nature => l10n.categoryBlurbNature,
        PlaceCategory.beach => l10n.categoryBlurbBeaches,
        PlaceCategory.hotels => l10n.categoryBlurbHotels,
        PlaceCategory.temples => l10n.categoryBlurbTemples,
        PlaceCategory.shopping => l10n.categoryBlurbShopping,
      };

  /// ALL-CAPS chip/overline style (no-op for Sinhala/Tamil scripts).
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PlaceCategory.home => l10n.categoryAll.toUpperCase(),
        _ => localizedDisplayName(l10n).toUpperCase(),
      };
}
