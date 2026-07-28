import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/reports_provider.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/report.dart';

/// Admin-only: lists open reports with Delete-review / Dismiss actions.
class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(openReportsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.moderation)),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text(context.l10n.couldNotLoadReports)),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(context.l10n.noOpenReports));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                const Divider(height: AppSpacing.xl),
            itemBuilder: (_, i) => _ReportRow(report: list[i]),
          );
        },
      ),
    );
  }
}

class _ReportRow extends ConsumerWidget {
  const _ReportRow({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review ${report.reviewId}', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(_reasonLabel(context, report.reason)),
        if (report.note != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(report.note!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            TextButton(
              onPressed: () => ref
                  .read(reportResolverProvider)
                  .resolve(report.id, actioned: true),
              child: Text(context.l10n.deleteReview),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => ref
                  .read(reportResolverProvider)
                  .resolve(report.id, actioned: false),
              child: Text(context.l10n.dismiss),
            ),
          ],
        ),
      ],
    );
  }

  String _reasonLabel(BuildContext context, ReportReason reason) =>
      switch (reason) {
        ReportReason.spam => context.l10n.reportReasonSpam,
        ReportReason.inappropriate => context.l10n.reportReasonInappropriate,
        ReportReason.fake => context.l10n.reportReasonFake,
        ReportReason.other => context.l10n.reportReasonOther,
      };
}
