import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale from `tokens/typography.css`.
/// Display roles use Bricolage Grotesque; everything else Plus Jakarta Sans.
/// Accessibility floor: body text never below 14px.
abstract final class AppTypography {
  static TextStyle _display(double size, double height, FontWeight w) =>
      GoogleFonts.bricolageGrotesque(
          fontSize: size, height: height, fontWeight: w);

  static TextStyle _text(double size, double height, FontWeight w) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, height: height, fontWeight: w);

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    TextStyle c(TextStyle s, [Color? color]) =>
        s.copyWith(color: color ?? onSurface);

    return TextTheme(
      displayLarge: c(_display(36, 1.08, FontWeight.w700)),
      displayMedium: c(_display(30, 1.12, FontWeight.w700)),
      headlineMedium: c(_display(26, 1.18, FontWeight.w700)),
      titleLarge: c(_display(22, 1.25, FontWeight.w600)),
      titleMedium: c(_text(17, 1.4, FontWeight.w600)),
      titleSmall: c(_text(15, 1.4, FontWeight.w600)),
      bodyLarge: c(_text(16, 1.55, FontWeight.w400)),
      bodyMedium: c(_text(15, 1.55, FontWeight.w400)),
      bodySmall: c(_text(14, 1.5, FontWeight.w400), onSurfaceVariant),
      labelLarge: c(_text(15, 1.2, FontWeight.w600)),
      labelMedium: c(_text(14, 1.2, FontWeight.w600)),
      labelSmall: c(
        _text(12, 1.2, FontWeight.w600).copyWith(letterSpacing: 1.2),
        onSurfaceVariant,
      ),
    );
  }

  /// ALL-CAPS category overline with wide tracking.
  static TextStyle overline(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6,
        color: color,
      );
}
