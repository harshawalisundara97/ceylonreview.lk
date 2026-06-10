import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Read-only star row: filled, half and empty stars in the amber
/// star color, e.g. 4.5 → ★★★★⯨.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CeylonTokens>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final position = i + 1;
        final IconData icon;
        if (rating >= position) {
          icon = Icons.star_rounded;
        } else if (rating >= position - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        final filled = rating >= position - 0.5;
        return Icon(icon,
            size: size, color: filled ? tokens.star : tokens.starEmpty);
      }),
    );
  }
}
