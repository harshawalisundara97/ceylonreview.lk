import 'package:flutter/material.dart';

import '../../domain/models/category.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Extra design tokens not covered by [ColorScheme], exposed via
/// `Theme.of(context).extension<CeylonTokens>()`.
class CeylonTokens extends ThemeExtension<CeylonTokens> {
  const CeylonTokens({
    required this.accent,
    required this.onAccent,
    required this.star,
    required this.starEmpty,
    required this.categoryTint,
    required this.categoryTintStrong,
  });

  final Color accent;
  final Color onAccent;
  final Color star;
  final Color starEmpty;
  final Color categoryTint;
  final Color categoryTintStrong;

  @override
  CeylonTokens copyWith({
    Color? accent,
    Color? onAccent,
    Color? star,
    Color? starEmpty,
    Color? categoryTint,
    Color? categoryTintStrong,
  }) =>
      CeylonTokens(
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        star: star ?? this.star,
        starEmpty: starEmpty ?? this.starEmpty,
        categoryTint: categoryTint ?? this.categoryTint,
        categoryTintStrong: categoryTintStrong ?? this.categoryTintStrong,
      );

  @override
  CeylonTokens lerp(CeylonTokens? other, double t) {
    if (other == null) return this;
    return CeylonTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      star: Color.lerp(star, other.star, t)!,
      starEmpty: Color.lerp(starEmpty, other.starEmpty, t)!,
      categoryTint: Color.lerp(categoryTint, other.categoryTint, t)!,
      categoryTintStrong:
          Color.lerp(categoryTintStrong, other.categoryTintStrong, t)!,
    );
  }
}

/// Builds the full [ThemeData] for the active category and brightness.
/// Swapping the category swaps the primary family; everything else is stable.
abstract final class AppTheme {
  static ThemeData of(PlaceCategory category, Brightness brightness) {
    final light = brightness == Brightness.light;
    final p = AppColors.paletteOf(category, brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: light ? AppColors.accentLight : AppColors.accentDark,
      onSecondary: light ? AppColors.onAccentLight : AppColors.onAccentDark,
      error: light ? AppColors.errorLight : AppColors.errorDark,
      onError: light ? Colors.white : const Color(0xFF690005),
      errorContainer:
          light ? AppColors.errorContainerLight : AppColors.errorContainerDark,
      surface: light ? AppColors.surfaceLight : AppColors.surfaceDark,
      onSurface: light ? AppColors.onSurfaceLight : AppColors.onSurfaceDark,
      onSurfaceVariant: light
          ? AppColors.onSurfaceVariantLight
          : AppColors.onSurfaceVariantDark,
      surfaceDim: light ? AppColors.surfaceDimLight : AppColors.surfaceDark,
      surfaceBright:
          light ? AppColors.surfaceLight : AppColors.surfaceBrightDark,
      surfaceContainerLowest: light
          ? AppColors.surfaceContainerLowestLight
          : AppColors.surfaceContainerLowestDark,
      surfaceContainerLow: light
          ? AppColors.surfaceContainerLowLight
          : AppColors.surfaceContainerLowDark,
      surfaceContainer: light
          ? AppColors.surfaceContainerLight
          : AppColors.surfaceContainerDark,
      surfaceContainerHigh: light
          ? AppColors.surfaceContainerHighLight
          : AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: light
          ? AppColors.surfaceContainerHighestLight
          : AppColors.surfaceContainerHighestDark,
      outline: light ? AppColors.outlineLight : AppColors.outlineDark,
      outlineVariant:
          light ? AppColors.outlineVariantLight : AppColors.outlineVariantDark,
      scrim: light ? AppColors.scrimLight : AppColors.scrimDark,
    );

    final textTheme = AppTypography.textTheme(
        colorScheme.onSurface, colorScheme.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      extensions: [
        CeylonTokens(
          accent: colorScheme.secondary,
          onAccent: colorScheme.onSecondary,
          star: light ? AppColors.starLight : AppColors.starDark,
          starEmpty: light ? AppColors.starEmptyLight : AppColors.starEmptyDark,
          categoryTint: p.tint,
          categoryTintStrong: p.tintStrong,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 1.5,
        shadowColor: colorScheme.scrim.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTap + 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTap + 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        indicatorColor: p.primaryContainer,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
