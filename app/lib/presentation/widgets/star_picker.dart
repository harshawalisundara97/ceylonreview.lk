import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Tappable 1–5 star rating input for Write Review.
class StarPicker extends StatelessWidget {
  const StarPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<CeylonTokens>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final star = i + 1;
        final filled = star <= value;
        return IconButton(
          onPressed: () => onChanged(star),
          iconSize: size,
          constraints: const BoxConstraints(
              minWidth: AppSpacing.minTap, minHeight: AppSpacing.minTap),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? tokens.star : tokens.starEmpty,
          ),
        );
      }),
    );
  }
}
