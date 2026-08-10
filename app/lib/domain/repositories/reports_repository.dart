import '../models/report.dart';

/// Reporting and moderating reviews.
abstract interface class ReportsRepository {
  Future<void> submit({
    required String reviewId,
    required String reporterId,
    required ReportReason reason,
    String? note,
  });

  /// Reports with status `open`, newest first. Admin-only per RLS.
  Future<List<Report>> fetchOpen();

  /// Marks a report `actioned` or `dismissed`. Admin-only per RLS.
  Future<void> resolve(String reportId, {required bool actioned});
}
