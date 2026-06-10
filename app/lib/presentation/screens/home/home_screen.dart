import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../application/category_theme_provider.dart';
import '../../../application/places_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/category.dart';
import '../../widgets/category_pill_row.dart';
import '../../widgets/place_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/user_avatar.dart';
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
    final tokens = theme.extension<CeylonTokens>()!;
    final user = ref.watch(authProvider);
    final activeCategory = ref.watch(activeCategoryProvider);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            // Greeting header on the category tint wash.
            Container(
              color: tokens.categoryTint,
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.lg, AppSpacing.gutter, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ayubowan${user != null ? ', ${user.name.split(' ').first}' : ''}!',
                                style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 2),
                            Text('Where to next in Sri Lanka?',
                                style: theme.textTheme.bodyMedium),
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
                      hintText: 'Search places, beaches, food…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searching
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CategoryPillRow(),

            if (searching)
              _SearchResults(query: _query, onOpen: _openPlace)
            else ...[
              const SectionHeader(title: 'Trending This Week'),
              _TrendingCarousel(onOpen: _openPlace),
              SectionHeader(
                title: activeCategory == PlaceCategory.home
                    ? 'Places You\'ll Love'
                    : activeCategory.displayName,
              ),
              _CategoryList(onOpen: _openPlace),
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
      height: 236,
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

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(activeCategoryProvider);
    final places = ref.watch(placesByCategoryProvider(category));

    return places.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const _ErrorNote(),
      data: (list) => Column(
        children: [
          for (final place in list)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
              child: PlaceCard(place: place, onTap: () => onOpen(place.id)),
            ),
        ],
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
                Text('No places found for "$query"',
                    style: theme.textTheme.bodyMedium),
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
        child: Text('Something went wrong. Pull to refresh.',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
