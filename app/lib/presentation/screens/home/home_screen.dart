import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/l10n_ext.dart';

import '../../../application/auth_provider.dart';
import '../../../application/category_theme_provider.dart';
import '../../../application/location_provider.dart';
import '../../../application/place_filters_provider.dart';
import '../../../application/places_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/place.dart';
import '../../l10n/category_labels.dart';
import '../../widgets/category_pill_row.dart';
import '../../widgets/filters_bottom_sheet.dart';
import '../../widgets/place_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/user_avatar.dart';
import '../add_place/add_place_screen.dart';
import '../category/category_screen.dart';
import '../place_detail/place_detail_screen.dart';

/// Home: greeting, hero search, category pills (drives re-theming),
/// Trending This Week carousel, and places list for the active category.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPlace(String placeId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(placeId: placeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final searching = _query.trim().isNotEmpty;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('home-scroll'),
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            // Kicker + greeting + search — no tinted wash, matches the
            // Nocturne prototype's plain-background Home header.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeKicker(DateFormat.EEEE(
                                      Localizations.localeOf(context)
                                          .toString())
                                  .format(DateTime.now())),
                              style: AppTypography.overline(
                                  theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              user != null
                                  ? l10n
                                      .homeGreeting(user.name.split(' ').first)
                                  : l10n.homeGreetingGuest,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      if (user != null) UserAvatar(name: user.name),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searching)
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                          SizedBox(
                            height: 24,
                            child: VerticalDivider(
                                width: 1,
                                color: theme.colorScheme.outlineVariant),
                          ),
                          Consumer(
                            builder: (context, ref, _) => IconButton(
                              icon: const Icon(Icons.filter_list_rounded),
                              color: theme.colorScheme.secondary,
                              tooltip: l10n.filters,
                              onPressed: () => showFiltersSheet(
                                  context, ref, activeCategory),
                            ),
                          ),
                        ],
                      ),
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CategoryPillRow(
              onCategorySelected: (category) {
                if (category != PlaceCategory.home) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CategoryScreen()),
                  );
                }
              },
            ),

            if (searching)
              _SearchResults(query: _query, onOpen: _openPlace)
            else ...[
              SectionHeader(title: l10n.trendingThisWeek),
              _TrendingCarousel(onOpen: _openPlace),
              SectionHeader(
                title: activeCategory == PlaceCategory.home
                    ? l10n.placesYoullLove
                    : activeCategory.localizedDisplayName(l10n),
              ),
              _MosaicGrid(onOpen: _openPlace),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendingCarousel extends ConsumerWidget {
  const _TrendingCarousel({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingPlacesProvider);
    return SizedBox(
      height: 254,
      child: trending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _ErrorNote(),
        data: (places) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          itemCount: places.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, i) => PlaceCard(
            place: places[i],
            width: 220,
            onTap: () => onOpen(places[i].id),
          ),
        ),
      ),
    );
  }
}

/// Two-column mosaic grid: the Nocturne prototype's "Fresh on the island"
/// layout — every 3rd tile (by index) is taller than its neighbors for a
/// staggered feel, tiles show category + name below the image (no overlay,
/// no save button, no review count — that's the separate "photo card" list
/// style used elsewhere, not this one).
class _MosaicGrid extends ConsumerWidget {
  const _MosaicGrid({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(activeCategoryProvider);
    final places = ref.watch(filteredPlacesProvider(category));
    final position = ref.watch(locationProvider).valueOrNull;
    final from = position == null
        ? null
        : latlong.LatLng(position.latitude, position.longitude);

    return places.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const _ErrorNote(),
      data: (list) {
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }
        final left = <Widget>[];
        final right = <Widget>[];
        for (var i = 0; i < list.length; i++) {
          final place = list[i];
          final tile = Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _MosaicTile(
              place: place,
              imageHeight: i % 3 == 0 ? 156 : 116,
              distanceKm: distanceToPlaceKm(from, place),
              onTap: () => onOpen(place.id),
            ),
          );
          (i.isEven ? left : right).add(tile);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: left)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(children: right)),
            ],
          ),
        );
      },
    );
  }
}

class _MosaicTile extends StatelessWidget {
  const _MosaicTile({
    required this.place,
    required this.imageHeight,
    required this.distanceKm,
    required this.onTap,
  });

  final Place place;
  final double imageHeight;
  final double? distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final seed = AppColors.seedOf(place.category);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    place.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(Icons.photo_rounded,
                          color: theme.colorScheme.outline, size: 28),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child:
                      Container(height: 2, color: seed.withValues(alpha: 0.55)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.category.localizedLabel(l10n),
                      style: AppTypography.overline(seed)),
                  const SizedBox(height: 4),
                  Text(
                    place.name,
                    style: theme.textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12,
                          color: theme.extension<CeylonTokens>()!.star),
                      const SizedBox(width: 3),
                      Text(place.ratingLabel,
                          style: theme.textTheme.labelSmall),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '· ${distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : place.district}',
                          style: theme.textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onOpen});

  final String query;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(placeSearchProvider(query));
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);

    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const _ErrorNote(),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Icon(Icons.travel_explore_rounded,
                    size: 48, color: theme.colorScheme.outline),
                const SizedBox(height: AppSpacing.md),
                Text(context.l10n.noPlacesFound(query),
                    style: theme.textTheme.bodyMedium),
                if (user != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: Text(context.l10n.cantFindAddPlace),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddPlaceScreen(initialName: query),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            for (final place in list)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
                child: PlaceCard(place: place, onTap: () => onOpen(place.id)),
              ),
          ],
        );
      },
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(context.l10n.pullToRefreshError,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
