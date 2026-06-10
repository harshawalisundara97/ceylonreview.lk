import 'package:flutter/material.dart';

import '../../domain/models/category.dart';

/// Primary-family colors for one category in one brightness.
/// Ported from `tokens/colors.css` in the design system.
class CategoryPalette {
  const CategoryPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.tint,
    required this.tintStrong,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Soft 8% tint of the category primary — screen washes, headers, chips.
  final Color tint;
  final Color tintStrong;
}

/// All color tokens of the Ceylon Review design system.
abstract final class AppColors {
  // ---- Brand constants ----
  static const ceylonGreen = Color(0xFF0F6E56);
  static const goldenAmber = Color(0xFFEF9F27);

  // ---- Accent (constant across categories) ----
  static const accentLight = goldenAmber;
  static const onAccentLight = Color(0xFF3D2600);
  static const accentDark = Color(0xFFFFB951);
  static const onAccentDark = Color(0xFF432C00);
  static const starLight = goldenAmber;
  static const starEmptyLight = Color(0xFFDAD7CF);
  static const starDark = Color(0xFFFFB951);
  static const starEmptyDark = Color(0xFF43483F);

  // ---- Neutral surfaces, light (warm, faint green undertone) ----
  static const surfaceLight = Color(0xFFFCFBF7);
  static const surfaceDimLight = Color(0xFFEFEDE6);
  static const surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const surfaceContainerLowLight = Color(0xFFF6F4EE);
  static const surfaceContainerLight = Color(0xFFF1EEE7);
  static const surfaceContainerHighLight = Color(0xFFEBE8E1);
  static const surfaceContainerHighestLight = Color(0xFFE5E2DB);
  static const onSurfaceLight = Color(0xFF1A1C19);
  static const onSurfaceVariantLight = Color(0xFF44483F);
  static const outlineLight = Color(0xFF757A70);
  static const outlineVariantLight = Color(0xFFDAD7CF);

  // ---- Neutral surfaces, dark (warm charcoal, never pure black) ----
  static const surfaceDark = Color(0xFF111513);
  static const surfaceBrightDark = Color(0xFF373B38);
  static const surfaceContainerLowestDark = Color(0xFF0C0F0D);
  static const surfaceContainerLowDark = Color(0xFF191D1A);
  static const surfaceContainerDark = Color(0xFF1D211E);
  static const surfaceContainerHighDark = Color(0xFF272B28);
  static const surfaceContainerHighestDark = Color(0xFF323633);
  static const onSurfaceDark = Color(0xFFE2E3DD);
  static const onSurfaceVariantDark = Color(0xFFC3C8BE);
  static const outlineDark = Color(0xFF8D9289);
  static const outlineVariantDark = Color(0xFF43483F);

  // ---- Semantic ----
  static const successLight = Color(0xFF2E7D49);
  static const errorLight = Color(0xFFB3261E);
  static const errorContainerLight = Color(0xFFF9DEDC);
  static const errorDark = Color(0xFFFFB4AB);
  static const errorContainerDark = Color(0xFF93000A);
  static const info = Color(0xFF00788F);

  static const scrimLight = Color(0x73101714);
  static const scrimDark = Color(0x99000000);

  // ---- Category palettes, light ----
  static const _light = <PlaceCategory, CategoryPalette>{
    PlaceCategory.home: CategoryPalette(
      primary: ceylonGreen,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFB9F0DC),
      onPrimaryContainer: Color(0xFF00210F),
      tint: Color(0xFFE5F4EE),
      tintStrong: Color(0xFFCDEBE0),
    ),
    PlaceCategory.food: CategoryPalette(
      primary: Color(0xFFC0512C),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFDBCE),
      onPrimaryContainer: Color(0xFF3A0B00),
      tint: Color(0xFFFBEBE4),
      tintStrong: Color(0xFFF7D8CB),
    ),
    PlaceCategory.nature: CategoryPalette(
      primary: Color(0xFF43811F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFC2F0A0),
      onPrimaryContainer: Color(0xFF0E2600),
      tint: Color(0xFFEAF4E1),
      tintStrong: Color(0xFFD7ECC4),
    ),
    PlaceCategory.beach: CategoryPalette(
      primary: Color(0xFF00788F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFABEDFB),
      onPrimaryContainer: Color(0xFF001F26),
      tint: Color(0xFFE1F3F7),
      tintStrong: Color(0xFFC2E9F1),
    ),
    PlaceCategory.hotels: CategoryPalette(
      primary: Color(0xFF7A4F9E),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEDDCFF),
      onPrimaryContainer: Color(0xFF2A004E),
      tint: Color(0xFFF3ECF9),
      tintStrong: Color(0xFFE6D7F3),
    ),
    PlaceCategory.temples: CategoryPalette(
      primary: Color(0xFF9A5B00),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFDDB3),
      onPrimaryContainer: Color(0xFF301400),
      tint: Color(0xFFF8EEDF),
      tintStrong: Color(0xFFF1DEC0),
    ),
    PlaceCategory.shopping: CategoryPalette(
      primary: Color(0xFFB11A60),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFD9E5),
      onPrimaryContainer: Color(0xFF3E0021),
      tint: Color(0xFFFBE9F1),
      tintStrong: Color(0xFFF6D3E2),
    ),
  };

  // ---- Category palettes, dark ----
  static const _dark = <PlaceCategory, CategoryPalette>{
    PlaceCategory.home: CategoryPalette(
      primary: Color(0xFF6FD9B6),
      onPrimary: Color(0xFF00382A),
      primaryContainer: Color(0xFF005140),
      onPrimaryContainer: Color(0xFF8FF5D2),
      tint: Color(0xFF18241F),
      tintStrong: Color(0xFF21332B),
    ),
    PlaceCategory.food: CategoryPalette(
      primary: Color(0xFFFFB59C),
      onPrimary: Color(0xFF5C1900),
      primaryContainer: Color(0xFF7A2D14),
      onPrimaryContainer: Color(0xFFFFDBCE),
      tint: Color(0xFF241813),
      tintStrong: Color(0xFF33211A),
    ),
    PlaceCategory.nature: CategoryPalette(
      primary: Color(0xFFA7DC7F),
      onPrimary: Color(0xFF1A3700),
      primaryContainer: Color(0xFF2C5410),
      onPrimaryContainer: Color(0xFFC2F0A0),
      tint: Color(0xFF1A2114),
      tintStrong: Color(0xFF243117),
    ),
    PlaceCategory.beach: CategoryPalette(
      primary: Color(0xFF5BD6F0),
      onPrimary: Color(0xFF003640),
      primaryContainer: Color(0xFF00586A),
      onPrimaryContainer: Color(0xFFABEDFB),
      tint: Color(0xFF132226),
      tintStrong: Color(0xFF0D2C34),
    ),
    PlaceCategory.hotels: CategoryPalette(
      primary: Color(0xFFD5BBFF),
      onPrimary: Color(0xFF41216B),
      primaryContainer: Color(0xFF5E3585),
      onPrimaryContainer: Color(0xFFEDDCFF),
      tint: Color(0xFF1E1826),
      tintStrong: Color(0xFF2B2138),
    ),
    PlaceCategory.temples: CategoryPalette(
      primary: Color(0xFFFFB95E),
      onPrimary: Color(0xFF4A2800),
      primaryContainer: Color(0xFF6E4100),
      onPrimaryContainer: Color(0xFFFFDDB3),
      tint: Color(0xFF231A0F),
      tintStrong: Color(0xFF34270F),
    ),
    PlaceCategory.shopping: CategoryPalette(
      primary: Color(0xFFFFB0CD),
      onPrimary: Color(0xFF5E1136),
      primaryContainer: Color(0xFF8A0E48),
      onPrimaryContainer: Color(0xFFFFD9E5),
      tint: Color(0xFF241620),
      tintStrong: Color(0xFF341F2C),
    ),
  };

  static CategoryPalette paletteOf(PlaceCategory category, Brightness b) =>
      (b == Brightness.light ? _light : _dark)[category]!;

  /// The marker / chip color identifying a category, independent of the
  /// active theme (always the light-mode primary for recognizability).
  static Color seedOf(PlaceCategory category) => _light[category]!.primary;
}
