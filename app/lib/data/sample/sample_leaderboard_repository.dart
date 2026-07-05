import '../../domain/models/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';

/// In-memory leaderboard for tests and offline use.
class SampleLeaderboardRepository implements LeaderboardRepository {
  static const _entries = <LeaderboardEntry>[
    LeaderboardEntry(userId: 'u-harsha', name: 'Harsha W.', points: 1240, rank: 1, rankChange: 0),
    LeaderboardEntry(userId: 'u-nadeesha', name: 'Nadeesha', points: 860, rank: 2, rankChange: 1),
    LeaderboardEntry(userId: 'u-dilan', name: 'Dilan', points: 705, rank: 3, rankChange: -1),
    LeaderboardEntry(userId: 'u-sanduni', name: 'Sanduni P.', points: 610, rank: 4, rankChange: 2),
    LeaderboardEntry(userId: 'u-kasun', name: 'Kasun R.', points: 540, rank: 5, rankChange: -1),
    LeaderboardEntry(userId: 'u-ishara', name: 'Ishara F.', points: 455, rank: 6),
  ];

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async => _entries;

  @override
  Future<LeaderboardEntry?> fetchMyRank(String userId) async {
    for (final entry in _entries) {
      if (entry.userId == userId) return entry;
    }
    return null;
  }
}
