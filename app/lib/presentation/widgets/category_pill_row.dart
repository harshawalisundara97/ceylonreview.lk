import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/category_theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/category.dart';

/// Horizontal category selector. Tapping a pill re-themes the entire app
/// (the signature 360ms cross-fade); tapping again clears back to brand.
class CategoryPillRow extends ConsumerWidget {
  const CategoryPillRow({super.key});

  static IconData iconOf(PlaceCategory c) => switch (c) {
        PlaceCategory.home => Icons.explore_rounded,
        PlaceCategory.food => Icons.restaurant_rounded,
        PlaceCategory.nature => Icons.forest_rounded,
        PlaceCategory.beach => Icons.beach_access_rounded,
        PlaceCategory.hotels => Icons.hotel_rounded,
        PlaceCategory.temples => Icons.temple_buddhist_rounded,
        PlaceCategory.shopping => Icons.shopping_bag_rounded,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeCategoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: PlaceCategory.selectable.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final category = PlaceCategory.selectable[i];
          final selected = category == active;
          final seed = AppColors.seedOf(category);

          return AnimatedContainer(
            duration: AppMotion.fast,
            child: Material(
              color: selected ? scheme.primary : scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: BorderSide(
                    color:
                        selected ? Colors.transparent : scheme.outlineVariant),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () =>
                    ref.read(activeCategoryProvider.notifier).toggle(category),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(iconOf(category),
                          size: 18,
                          color: selected ? scheme.onPrimary : seed),
                      const SizedBox(width: 6),
                      Text(
                        category.label,
                        style: AppTypography.overline(
                          selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
