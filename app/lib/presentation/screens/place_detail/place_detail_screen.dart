import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../application/favorites_provider.dart';
import '../../../application/places_provider.dart';
import '../../../application/repository_providers.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/place.dart';
import '../../l10n/category_labels.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/review_tile.dart';
import '../write_review/write_review_screen.dart';

/// Place Detail: full-bleed hero photo with scrim, rating summary,
/// description, reviews, and Write a Review CTA.
class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeByIdProvider(placeId));

    return placeAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.couldNotLoadThisPlace)),
      ),
      data: (place) {
        if (place == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(context.l10n.thisPlaceNoLongerExists)),
          );
        }
        return _PlaceDetailBody(place: place);
      },
    );
  }
}

class _PlaceDetailBody extends ConsumerWidget {
  const _PlaceDetailBody({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    final reviews = ref.watch(reviewsForPlaceProvider(place.id));
    final isFavorite =
        (ref.watch(myFavoriteIdsProvider).valueOrNull ?? const {})
            .contains(place.id);
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
    final seed = AppColors.seedOf(place.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 322,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    place.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: tokens.categoryTintStrong),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment(0, -0.6),
                        colors: [
                          Color(0xCC000000),
                          Color(0x66000000),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.35, 0.75],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xl,
                    left: AppSpacing.gutter,
                    right: AppSpacing.gutter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeroCircleButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        Row(
                          children: [
                            _HeroCircleButton(
                              icon: isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              iconColor: isFavorite ? seed : Colors.white,
                              onTap: () => ref
                                  .read(myFavoriteIdsProvider.notifier)
                                  .toggle(place.id),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _HeroCircleButton(
                              icon: Icons.ios_share_rounded,
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text(context.l10n.share))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.gutter,
                    right: AppSpacing.gutter,
                    bottom: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(place.category.localizedLabel(context.l10n),
                                style: AppTypography.overline(seed)),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(place.district,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTypography.overline(Colors.white70)),
                            ),
                            if (place.addedBy != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text('· ${context.l10n.community}',
                                  style:
                                      AppTypography.overline(Colors.white70)),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          place.name,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(place.ratingLabel,
                          style: theme.textTheme.displayMedium),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingStars(rating: place.rating),
                          Text(context.l10n.nReviews(place.reviewCountLabel),
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const Spacer(),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: theme.colorScheme.error,
                          onPressed: () =>
                              _confirmDeletePlace(context, ref, place.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(place.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  WriteReviewScreen(initialPlaceId: place.id),
                            ),
                          ),
                          child: Text(context.l10n.writeAReview),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text(
                                      context.l10n.directionsOpenInMapTab))),
                          child: Text(context.l10n.getDirections),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.l10n.whatPeopleSaid,
                          style: theme.textTheme.titleLarge),
                      Text(context.l10n.mostHelpful,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                  reviews.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text(context.l10n.couldNotLoadReviews),
                    ),
                    data: (list) {
                      final reviewPhotos = [
                        for (final r in list) ...r.photoUrls,
                      ];
                      final photos = [
                        if (place.imageUrl.isNotEmpty) place.imageUrl,
                        ...reviewPhotos,
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reviewPhotos.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(context.l10n.travellerPhotos,
                                    style: theme.textTheme.titleLarge),
                                Text('${photos.length}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.secondary)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              height: 96,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: photos.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () => PhotoViewer.open(context,
                                      photoUrls: photos, initialIndex: i),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      photos[i],
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 96,
                                        height: 96,
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (list.isEmpty)
                            Text(
                              context.l10n.noReviewsYetBeFirst,
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            Column(
                              children: [
                                for (final review in list)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md),
                                        child: ReviewTile(review: review),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeletePlace(
    BuildContext context, WidgetRef ref, String placeId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.deletePlaceConfirmTitle),
      content: Text(context.l10n.deletePlaceConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.deletePlace),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(placesRepositoryProvider).delete(placeId);
    ref.invalidate(allPlacesProvider);
    ref.invalidate(placesByCategoryProvider);
    ref.invalidate(trendingPlacesProvider);
    if (context.mounted) Navigator.of(context).maybePop();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotDeletePlace)),
      );
    }
  }
}

/// Icon button legible over the hero photo (back, save, share).
class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black38,
      shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
