import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../domain/models/review.dart';
import 'rating_stars.dart';
import 'user_avatar.dart';

/// One review in a place's review list.
class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = review.createdAt;
    final date = '${_months[d.month - 1]} ${d.day}, ${d.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: review.authorName, radius: 16),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName,
                        style: theme.textTheme.titleSmall),
                    Text(date, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
