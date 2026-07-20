import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/favorites_provider.dart';
import '../../../application/places_provider.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/l10n_ext.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: _CircleBackButton(),
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
                        end: Alignment(0, -0.2),
                        colors: [Color(0xA6000000), Colors.transparent],
                      ),
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
                                style: AppTypography.overline(Colors.white)),
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
                      Icon(Icons.place_rounded,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 2),
                      Text(place.district,
                          style: theme.textTheme.titleSmall),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? Colors.redAccent
                              : theme.colorScheme.outline,
                        ),
                        onPressed: () => ref
                            .read(myFavoriteIdsProvider.notifier)
                            .toggle(place.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(place.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.rate_review_rounded),
                          label: Text(context.l10n.writeAReview),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  WriteReviewScreen(initialPlaceId: place.id),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.directions_rounded),
                          label: Text(context.l10n.getDirections),
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text(
                                      context.l10n.directionsOpenInMapTab))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(context.l10n.reviews, style: theme.textTheme.titleLarge),
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
                            Text(context.l10n.photos, style: theme.textTheme.titleLarge),
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
                                        color: theme
                                            .colorScheme.surfaceContainerHighest,
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
                                  ReviewTile(review: review),
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

/// Back button legible over the hero photo.
class _CircleBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: Colors.black38,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
