import '../models/leaderboard_entry.dart';

/// Read access to the points leaderboard. Only profiles with at least one
/// review (points > 0) appear — a leaderboard of all-zero accounts isn't
/// useful, and it keeps "nobody has reviewed yet" a simple empty list.
abstract interface class LeaderboardRepository {
  /// Everyone with points > 0, ranked highest first.
  Future<List<LeaderboardEntry>> fetchLeaderboard();

  /// The given user's own entry, or null if they have zero points.
  Future<LeaderboardEntry?> fetchMyRank(String userId);
}
