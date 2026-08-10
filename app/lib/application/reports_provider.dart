import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/report.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

final openReportsProvider = FutureProvider<List<Report>>(
    (ref) => ref.watch(reportsRepositoryProvider).fetchOpen());

/// Submits a report as the signed-in user.
class ReportSubmitter {
  ReportSubmitter(this._ref);

  final Ref _ref;

  Future<void> submit({
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) async {
    final user = _ref.read(authProvider);
    if (user == null) {
      throw StateError('You must be signed in to report a review.');
    }
    await _ref.read(reportsRepositoryProvider).submit(
          reviewId: reviewId,
          reporterId: user.id,
          reason: reason,
          note: note,
        );
    _ref.invalidate(openReportsProvider);
  }
}

final reportSubmitterProvider = Provider((ref) => ReportSubmitter(ref));

/// Resolves a report: `actioned` deletes the underlying review, `dismissed`
/// leaves it untouched. Either way the report's status is updated.
class ReportResolver {
  ReportResolver(this._ref);

  final Ref _ref;

  Future<void> resolve(String reportId, {required bool actioned}) async {
    if (actioned) {
      final reports = await _ref.read(reportsRepositoryProvider).fetchOpen();
      final report = reports.firstWhere((r) => r.id == reportId);
      await _ref.read(reviewsRepositoryProvider).delete(report.reviewId);
    }
    await _ref
        .read(reportsRepositoryProvider)
        .resolve(reportId, actioned: actioned);
    _ref.invalidate(openReportsProvider);
  }
}

final reportResolverProvider = Provider((ref) => ReportResolver(ref));
