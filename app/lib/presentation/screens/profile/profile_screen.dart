import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../application/category_theme_provider.dart';
import '../../../application/favorites_provider.dart';
import '../../../application/places_provider.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/place_card.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/language_picker.dart';
import '../../../core/l10n_ext.dart';
import '../place_detail/place_detail_screen.dart';

/// Profile: avatar + identity, dark-mode toggle, the user's reviews,
/// and sign out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final myReviews = ref.watch(myReviewsProvider);
    final favoriteIds = ref.watch(myFavoriteIdsProvider);
    final placesAsync = ref.watch(allPlacesProvider);

    if (user == null) {
      // The router returns to Login when signed out; this is a fallback.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            Container(
              color: tokens.categoryTint,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  UserAvatar(name: user.name, radius: 36),
                  const SizedBox(height: AppSpacing.md),
                  Text(user.name, style: theme.textTheme.headlineMedium),
                  Text(user.email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            SwitchListTile(
              value: isDark,
              onChanged: (v) => ref
                  .read(themeModeProvider.notifier)
                  .set(v ? ThemeMode.dark : ThemeMode.light),
              secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
              title: Text(context.l10n.darkMode),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(context.l10n.language),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showLanguagePicker(context),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.xl, AppSpacing.gutter, AppSpacing.sm),
              child: Text(context.l10n.yourFavorites, style: theme.textTheme.titleLarge),
            ),
            favoriteIds.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: Text(context.l10n.couldNotLoadYourFavorites),
              ),
              data: (ids) {
                final places = (placesAsync.valueOrNull ?? [])
                    .where((p) => ids.contains(p.id))
                    .toList();
                if (places.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Text(
                      context.l10n.noFavoritesYetTapHeart,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final place in places)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0,
                            AppSpacing.gutter, AppSpacing.md),
                        child: PlaceCard(
                          place: place,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailScreen(placeId: place.id),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.xl, AppSpacing.gutter, AppSpacing.sm),
              child: Text(context.l10n.yourReviews, style: theme.textTheme.titleLarge),
            ),
            myReviews.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: Text(context.l10n.couldNotLoadYourReviews),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Text(
                      context.l10n.noReviewsYetVisit,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                final placeNames = {
                  for (final p in placesAsync.valueOrNull ?? []) p.id: p.name,
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final review in reviews)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              placeNames[review.placeId] ?? context.l10n.aPlace,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(color: theme.colorScheme.primary),
                            ),
                            ReviewTile(review: review),
                            const Divider(height: 1),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: Text(context.l10n.signOut),
                onPressed: () => ref.read(authProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
