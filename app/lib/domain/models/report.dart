/// A reason a user gives when flagging a review.
enum ReportReason {
  spam,
  inappropriate,
  fake,
  other;

  /// Localized display label — the caller passes in `AppLocalizations`
  /// since domain models don't depend on the presentation layer directly.
}

enum ReportStatus { open, actioned, dismissed }

/// A user's flag on a review, pending admin review.
class Report {
  const Report({
    required this.id,
    required this.reviewId,
    required this.reporterId,
    required this.reason,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String reviewId;
  final String reporterId;
  final ReportReason reason;
  final String? note;
  final ReportStatus status;
  final DateTime createdAt;
}
