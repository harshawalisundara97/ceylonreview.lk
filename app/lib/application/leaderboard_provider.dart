import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/leaderboard_entry.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>(
    (ref) => ref.watch(leaderboardRepositoryProvider).fetchLeaderboard());

final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Future.value(null);
  return ref.watch(leaderboardRepositoryProvider).fetchMyRank(user.id);
});
