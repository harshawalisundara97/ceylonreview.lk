/// One row of the leaderboard: a ranked profile with all-time points and,
/// if a daily snapshot exists for this user, how their rank moved since
/// yesterday.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.points,
    required this.rank,
    this.rankChange,
  });

  final String userId;
  final String name;
  final int points;
  final int rank;

  /// Positive = moved up N spots since yesterday's snapshot, negative =
  /// down N spots. Null if the user has no snapshot yet (e.g. joined today).
  final int? rankChange;
}
