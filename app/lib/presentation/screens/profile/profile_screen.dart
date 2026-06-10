import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/auth_provider.dart';
import '../../../application/category_theme_provider.dart';
import '../../../application/places_provider.dart';
import '../../../application/reviews_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/review_tile.dart';
import '../../widgets/user_avatar.dart';

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
              title: const Text('Dark Mode'),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.xl, AppSpacing.gutter, AppSpacing.sm),
              child:
                  Text('Your Reviews', style: theme.textTheme.titleLarge),
            ),
            myReviews.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: Text('Could not load your reviews.'),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Text(
                      'No reviews yet. Visit a place and share your experience!',
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
                              placeNames[review.placeId] ?? 'A place',
                              style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary),
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
                label: const Text('Sign Out'),
                onPressed: () => ref.read(authProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
