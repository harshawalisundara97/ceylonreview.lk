import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/l10n_ext.dart';

import '../../../application/category_theme_provider.dart';
import '../../../application/location_provider.dart';
import '../../../application/place_filters_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/category.dart';
import '../../l10n/category_labels.dart';
import '../../widgets/category_pill_row.dart';
import '../../widgets/filters_bottom_sheet.dart';
import '../../widgets/place_card.dart';
import '../place_detail/place_detail_screen.dart';

/// Category feed: themed header with the active category, pill switcher,
/// and a two-column place grid. Reached by tapping a category pill on Home.
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

    final seed = AppColors.seedOf(category);
    final wash = tokens.categoryTintStrong;

    Widget header([int? placeCount, int? reviewCount]) => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [wash, wash.withValues(alpha: 0)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md,
              AppSpacing.gutter, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HeaderCircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  _HeaderCircleButton(
                    icon: Icons.tune_rounded,
                    tooltip: l10n.filters,
                    showBadge: ref.watch(placeFiltersProvider).isActive,
                    onTap: () => showFiltersSheet(context, ref, category),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (placeCount != null && reviewCount != null) ...[
                Text(
                  '${l10n.nPlaces('$placeCount')} · ${l10n.nReviews('$reviewCount')}',
                  style: AppTypography.overline(seed),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                category == PlaceCategory.home
                    ? l10n.exploreSriLanka
                    : category.localizedDisplayName(l10n),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  category.localizedBlurb(l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      seed.withValues(alpha: 0.5),
                      seed.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: places.when(
          loading: () => Column(
            children: [
              header(),
              const Expanded(
                  child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (_, __) => Column(
            children: [
              header(),
              Expanded(child: Center(child: Text(l10n.couldNotLoadPlaces))),
            ],
          ),
          data: (list) => CustomScrollView(
            key: const Key('category-scroll'),
            slivers: [
              SliverToBoxAdapter(
                child: header(
                  list.length,
                  list.fold<int>(0, (sum, p) => sum + p.reviewCount),
                ),
              ),
              const SliverToBoxAdapter(child: CategoryPillRow()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                    AppSpacing.lg, AppSpacing.gutter, AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth =
                          (constraints.maxWidth - AppSpacing.md) / 2;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          for (final place in list)
                            PlaceCard(
                              place: place,
                              width: tileWidth,
                              distanceKm: distanceToPlaceKm(from, place),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaceDetailScreen(placeId: place.id),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.surface.withValues(alpha: 0.6),
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Badge(
              isLabelVisible: showBadge,
              child: Icon(icon, color: scheme.onSurface, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
