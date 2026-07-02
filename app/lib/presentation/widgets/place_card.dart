import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/place.dart';

/// Place card: full-bleed photo with bottom scrim, name, category overline,
/// rating and review count. Two layouts: carousel (fixed width) and list.
class PlaceCard extends ConsumerWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.width,
    this.distanceKm,
  });

  final Place place;
  final VoidCallback onTap;

  /// When set, renders the compact carousel layout.
  final double? width;

  /// Distance from the device's current location, in kilometres. Shown next
  /// to the district when available.
  final double? distanceKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    final seed = AppColors.seedOf(place.category);
    final isFavorite =
        (ref.watch(myFavoriteIdsProvider).valueOrNull ?? const {})
            .contains(place.id);

    final card = Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: width != null ? 4 / 3 : 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    place.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: tokens.categoryTintStrong,
                      alignment: Alignment.center,
                      child: Icon(Icons.photo_rounded,
                          color: theme.colorScheme.outline, size: 36),
                    ),
                  ),
                  // Bottom scrim for text legibility over photography.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment(0, -0.1),
                        colors: [Color(0xA6000000), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.sm,
                    child: Text(
                      place.category.label,
                      style: AppTypography.overline(Colors.white),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () => ref
                            .read(myFavoriteIdsProvider.notifier)
                            .toggle(place.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: tokens.star),
                      const SizedBox(width: 2),
                      Text(place.ratingLabel,
                          style: theme.textTheme.labelMedium),
                      Flexible(
                        child: Text(
                          ' · ${place.reviewCountLabel} reviews',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.place_rounded, size: 14, color: seed),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          distanceKm != null
                              ? '${distanceKm!.toStringAsFixed(1)} km'
                              : place.district,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (place.isOpenNow != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _OpenNowChip(isOpen: place.isOpenNow!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return width != null ? SizedBox(width: width, child: card) : card;
  }
}

class _OpenNowChip extends StatelessWidget {
  const _OpenNowChip({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOpen ? Colors.green.shade600 : theme.colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(
          isOpen ? 'Open now' : 'Closed',
          style: theme.textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
