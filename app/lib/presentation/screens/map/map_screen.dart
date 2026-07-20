import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n_ext.dart';

import '../../../application/auth_provider.dart';
import '../../../application/category_theme_provider.dart';
import '../../../application/places_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/place.dart';
import '../../widgets/category_pill_row.dart';
import '../../widgets/rating_stars.dart';
import '../add_place/add_place_screen.dart';
import '../place_detail/place_detail_screen.dart';

/// Map of Sri Lanka with category-colored markers (OpenStreetMap tiles —
/// free, no API key). Tapping a marker opens a place summary sheet.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  /// Center of Sri Lanka.
  static const _islandCenter = LatLng(7.5, 80.7);

  void _showPlaceSheet(BuildContext context, Place place) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => _PlaceSheet(place: place),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(activeCategoryProvider);
    final placesAsync = ref.watch(placesByCategoryProvider(category));
    final user = ref.watch(authProvider);
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              tooltip: l10n.addAPlace,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPlaceScreen()),
              ),
              child: const Icon(Icons.add_location_alt_rounded),
            ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.couldNotLoadMap)),
        data: (places) => Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _islandCenter,
                initialZoom: 7.3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ceylonreview.ceylon_review',
                ),
                MarkerLayer(
                  markers: [
                    for (final place in places)
                      Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showPlaceSheet(context, place),
                          child: Icon(
                            Icons.location_pin,
                            size: 40,
                            color: AppColors.seedOf(place.category),
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Category filter floating over the map.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: CategoryPillRow(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceSheet extends StatelessWidget {
  const _PlaceSheet({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              RatingStars(rating: place.rating, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text('${place.ratingLabel} · ${l10n.nReviews(place.reviewCountLabel)}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            place.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaceDetailScreen(placeId: place.id),
                ),
              );
            },
            child: Text(l10n.viewPlace),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}
