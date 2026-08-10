import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/report.dart';
import '../../domain/repositories/reports_repository.dart';

/// Reports backed by the Supabase `reports` table.
class SupabaseReportsRepository implements ReportsRepository {
  SupabaseReportsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> submit({
    required String reviewId,
    required String reporterId,
    required ReportReason reason,
    String? note,
  }) async {
    await _client.from('reports').insert({
      'review_id': reviewId,
      'reporter_id': reporterId,
      'reason': reason.name,
      'note': note,
    });
  }

  @override
  Future<List<Report>> fetchOpen() async {
    final rows = await _client
        .from('reports')
        .select()
        .eq('status', 'open')
        .order('created_at', ascending: false);
    return rows.map(_reportFromRow).toList();
  }

  @override
  Future<void> resolve(String reportId, {required bool actioned}) async {
    await _client
        .from('reports')
        .update({'status': actioned ? 'actioned' : 'dismissed'})
        .eq('id', reportId);
  }
}

Report _reportFromRow(Map<String, dynamic> row) => Report(
      id: row['id'] as String,
      reviewId: row['review_id'] as String,
      reporterId: row['reporter_id'] as String,
      reason: ReportReason.values.byName(row['reason'] as String),
      note: row['note'] as String?,
      status: switch (row['status'] as String) {
        'actioned' => ReportStatus.actioned,
        'dismissed' => ReportStatus.dismissed,
        _ => ReportStatus.open,
      },
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
    );
