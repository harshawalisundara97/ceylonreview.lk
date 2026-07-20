import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/l10n_ext.dart';

import '../../../application/category_theme_provider.dart';
import '../../../application/location_provider.dart';
import '../../../application/place_filters_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/category.dart';
import '../../l10n/category_labels.dart';
import '../../widgets/category_pill_row.dart';
import '../../widgets/filters_bottom_sheet.dart';
import '../../widgets/place_card.dart';
import '../place_detail/place_detail_screen.dart';

/// Category feed: themed header with the active category, pill switcher,
/// and the full place list. Backs the "Feed" tab.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final tokens = theme.extension<CeylonTokens>()!;
    final category = ref.watch(activeCategoryProvider);
    final places = ref.watch(filteredPlacesProvider(category));
    final position = ref.watch(locationProvider).valueOrNull;
    final from = position == null
        ? null
        : latlong.LatLng(position.latitude, position.longitude);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: tokens.categoryTint,
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.lg, AppSpacing.gutter, AppSpacing.lg),
              child: Row(
                children: [
                  Icon(CategoryPillRow.iconOf(category),
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      category == PlaceCategory.home
                          ? l10n.exploreSriLanka
                          : category.localizedDisplayName(l10n),
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: Badge(
                      isLabelVisible: ref.watch(placeFiltersProvider).isActive,
                      child: const Icon(Icons.tune_rounded),
                    ),
                    tooltip: l10n.filters,
                    onPressed: () => showFiltersSheet(context, ref, category),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CategoryPillRow(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: places.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    Center(child: Text(l10n.couldNotLoadPlaces)),
                data: (list) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0,
                      AppSpacing.gutter, AppSpacing.xl),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) => PlaceCard(
                    place: list[i],
                    distanceKm: distanceToPlaceKm(from, list[i]),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PlaceDetailScreen(placeId: list[i].id),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
