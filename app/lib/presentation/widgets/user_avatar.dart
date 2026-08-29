import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Initials avatar. In dark mode this is the Nocturne prototype's fixed
/// accent-bright circle (not category-tinted); light mode keeps the
/// existing category-tinted look.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: isDark ? AppColors.accentDark : scheme.primaryContainer,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: isDark ? AppColors.surfaceDark : scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
