import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

/// Leaderboard backed by `public.profiles` (points) and
/// `public.leaderboard_snapshots` (yesterday's rank, for the rank-change
/// arrows).
class SupabaseLeaderboardRepository implements LeaderboardRepository {
  SupabaseLeaderboardRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, int>> _latestSnapshotRanks() async {
    final rows = await _client
        .from('leaderboard_snapshots')
        .select('user_id, rank, snapshot_date')
        .order('snapshot_date', ascending: false);
    final latestByUser = <String, int>{};
    for (final row in rows) {
      final userId = row['user_id'] as String;
      latestByUser.putIfAbsent(userId, () => row['rank'] as int);
    }
    return latestByUser;
  }

  Future<List<LeaderboardEntry>> _rankedProfiles() async {
    final rows = await _client
        .from('profiles')
        .select('id, name, points, created_at')
        .gt('points', 0)
        .order('points', ascending: false)
        .order('created_at', ascending: true);
    final snapshots = await _latestSnapshotRanks();

    final entries = <LeaderboardEntry>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final userId = row['id'] as String;
      final rank = i + 1;
      final previousRank = snapshots[userId];
      entries.add(LeaderboardEntry(
        userId: userId,
        name: row['name'] as String,
        points: row['points'] as int,
        rank: rank,
        rankChange: previousRank == null ? null : previousRank - rank,
      ));
    }
    return entries;
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() => _rankedProfiles();

  @override
  Future<LeaderboardEntry?> fetchMyRank(String userId) async {
    final entries = await _rankedProfiles();
    for (final entry in entries) {
      if (entry.userId == userId) return entry;
    }
    return null;
  }
}
