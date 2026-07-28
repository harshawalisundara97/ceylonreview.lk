import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth_provider.dart';
import '../../application/reports_provider.dart';
import '../../core/l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/report.dart';
import '../../domain/models/review.dart';
import 'photo_viewer.dart';
import 'rating_stars.dart';
import 'user_avatar.dart';

/// One review in a place's review list.
class ReviewTile extends ConsumerWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final d = review.createdAt;
    final date = '${_months[d.month - 1]} ${d.day}, ${d.year}';
    final currentUserId = ref.watch(authProvider)?.id;
    final isOwnReview = currentUserId != null && currentUserId == review.authorId;

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
              if (!isOwnReview) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  tooltip: context.l10n.reportThisReview,
                  onPressed: () => _showReportSheet(context, ref),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: theme.textTheme.bodyMedium),
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => PhotoViewer.open(context,
                      photoUrls: review.photoUrls, initialIndex: i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.photoUrls[i],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ReportSheet(reviewId: review.id),
    );
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(reportSubmitterProvider).submit(
            reviewId: widget.reviewId,
            reason: _reason!,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.reportSubmittedThankYou)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotSubmitReport)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = {
      ReportReason.spam: context.l10n.reportReasonSpam,
      ReportReason.inappropriate: context.l10n.reportReasonInappropriate,
      ReportReason.fake: context.l10n.reportReasonFake,
      ReportReason.other: context.l10n.reportReasonOther,
    };
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.reportThisReview,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final entry in reasons.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _reason == entry.key,
                  onSelected: (_) => setState(() => _reason = entry.key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            decoration:
                InputDecoration(labelText: context.l10n.reportNoteOptional),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: (_reason == null || _busy) ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(context.l10n.submitReport),
          ),
        ],
      ),
    );
  }
}
