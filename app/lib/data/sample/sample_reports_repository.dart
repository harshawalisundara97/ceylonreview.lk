import '../../domain/models/report.dart';
import '../../domain/repositories/reports_repository.dart';

/// In-memory implementation: reports persist for the session.
class SampleReportsRepository implements ReportsRepository {
  final List<Report> _reports = [];
  int _nextId = 1;

  @override
  Future<void> submit({
    required String reviewId,
    required String reporterId,
    required ReportReason reason,
    String? note,
  }) async {
    _reports.add(Report(
      id: 'report${_nextId++}',
      reviewId: reviewId,
      reporterId: reporterId,
      reason: reason,
      note: note,
      status: ReportStatus.open,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<List<Report>> fetchOpen() async {
    final open = _reports.where((r) => r.status == ReportStatus.open).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return open;
  }

  @override
  Future<void> resolve(String reportId, {required bool actioned}) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;
    final r = _reports[index];
    _reports[index] = Report(
      id: r.id,
      reviewId: r.reviewId,
      reporterId: r.reporterId,
      reason: r.reason,
      note: r.note,
      status: actioned ? ReportStatus.actioned : ReportStatus.dismissed,
      createdAt: r.createdAt,
    );
  }
}
