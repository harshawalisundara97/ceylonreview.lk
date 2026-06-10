import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/place.dart';

/// Place card: full-bleed photo with bottom scrim, name, category overline,
/// rating and review count. Two layouts: carousel (fixed width) and list.
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.width,
  });

  final Place place;
  final VoidCallback onTap;

  /// When set, renders the compact carousel layout.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    final seed = AppColors.seedOf(place.category);

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
                      Text(
                        ' · ${place.reviewCountLabel} reviews',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Icon(Icons.place_rounded, size: 14, color: seed),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          place.district,
                          style: theme.textTheme.bodySmall,
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

    return width != null ? SizedBox(width: width, child: card) : card;
  }
}
