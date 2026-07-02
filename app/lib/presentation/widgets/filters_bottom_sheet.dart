import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/location_provider.dart';
import '../../application/place_filters_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/category.dart';
import '../../domain/models/place_filters.dart';

/// Categories where a price level is meaningful. Hidden for temples, nature,
/// and beach — those places aren't priced.
bool categoryHasPricing(PlaceCategory category) => switch (category) {
      PlaceCategory.food || PlaceCategory.hotels || PlaceCategory.shopping => true,
      PlaceCategory.home => true,
      PlaceCategory.nature || PlaceCategory.beach || PlaceCategory.temples => false,
    };

Future<void> showFiltersSheet(
    BuildContext context, WidgetRef ref, PlaceCategory category) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => _FiltersSheet(category: category),
  );
}

class _FiltersSheet extends ConsumerWidget {
  const _FiltersSheet({required this.category});

  final PlaceCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(placeFiltersProvider);
    final notifier = ref.read(placeFiltersProvider.notifier);
    final location = ref.watch(locationProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          if (categoryHasPricing(category)) ...[
            Text('Price', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final level in [1, 2, 3])
                  ChoiceChip(
                    label: Text('₨' * level),
                    selected: filters.priceLevel == level,
                    onSelected: (selected) =>
                        notifier.setPriceLevel(selected ? level : null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('Hours', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open now'),
            value: filters.openNowOnly,
            onChanged: notifier.setOpenNowOnly,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Sort by', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final sort in PlaceSort.values)
                ChoiceChip(
                  label: Text(sort.label),
                  selected: filters.sortBy == sort,
                  onSelected: (selected) {
                    if (!selected) return;
                    if (sort == PlaceSort.distance && location.valueOrNull == null) {
                      ref.read(locationProvider.notifier).refresh();
                    }
                    notifier.setSortBy(sort);
                  },
                ),
            ],
          ),
          if (filters.sortBy == PlaceSort.distance &&
              location.valueOrNull == null &&
              !location.isLoading) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enable location access to sort by distance.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              TextButton(
                onPressed: notifier.reset,
                child: const Text('Reset'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
