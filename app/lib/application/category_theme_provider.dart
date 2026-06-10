import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/category.dart';

/// The active category driving the app-wide re-theming.
/// [PlaceCategory.home] = default Ceylon Green brand palette.
class ActiveCategoryNotifier extends Notifier<PlaceCategory> {
  @override
  PlaceCategory build() => PlaceCategory.home;

  void select(PlaceCategory category) => state = category;

  /// Tapping the already-active category clears back to the brand palette.
  void toggle(PlaceCategory category) =>
      state = (state == category) ? PlaceCategory.home : category;
}

final activeCategoryProvider =
    NotifierProvider<ActiveCategoryNotifier, PlaceCategory>(
        ActiveCategoryNotifier.new);

/// User's light/dark preference; null follows the system setting.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
