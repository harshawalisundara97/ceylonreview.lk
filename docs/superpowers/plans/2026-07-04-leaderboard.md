# Leaderboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every posted review earns the author 10 points; a new Leaderboard tab shows everyone ranked by all-time points, with an animated podium for the top 3, a "your rank" card, and daily rank-change arrows.

**Architecture:** A Postgres trigger on `reviews` recomputes `profiles.points` (mirrors the existing places-rating trigger). A `pg_cron` job snapshots ranks once a day into `leaderboard_snapshots` so the UI can show rank deltas. A new `LeaderboardRepository` (three-file pattern: interface / Supabase / sample) feeds two Riverpod providers, consumed by a new `LeaderboardScreen` with hand-rolled Flutter animations (no new animation package) and a 6th bottom-nav tab.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres trigger + pg_cron), no new pub.dev dependencies.

**Spec:** `docs/superpowers/specs/2026-07-04-leaderboard-design.md`.

## Global Constraints

- Points are flat: 10 per review, no bonuses. Recomputed via `count(*) * 10`, not incremented.
- Ranking is all-time and live — no weekly reset, no leagues.
- `fetchLeaderboard()` returns only profiles with `points > 0` (people who've never reviewed are excluded entirely, not shown at the bottom).
- `fetchMyRank()` returns null when the signed-in user has 0 points.
- Rank-change arrows (`rankChange`) come from `leaderboard_snapshots`; null when there's no snapshot yet for that user (new accounts) — never render an arrow for null.
- Avatars reuse the existing `UserAvatar` widget (initials, colored circle) — no photo upload work in this feature.
- Animations are built with Flutter's own `TweenAnimationBuilder`/`AnimationController` — no new pub.dev animation package.
- Bottom nav order becomes: Home, Map, Leaderboard, Post, Feed, Profile.
- Match the existing three-file repository pattern and provider style exactly (see `favoritesRepositoryProvider` / `FavoritesRepository` as the closest analog — read-mostly, per-user).
- `flutter analyze` must report "No issues found!" before every commit; run the full `flutter test` suite before every commit.

---

### Task 1: Supabase backend — points trigger, snapshot table, cron job

**Files:** none in the repo — applied to Supabase project `jrepeqykdgsckrlvujnt` via the SQL editor (the MCP `apply_migration`/`execute_sql` tools were unavailable in earlier sessions this project; if they're available now, use `apply_migration` instead of asking the user to run SQL manually).

**Interfaces:**
- Produces: `profiles.points integer not null default 0`; table `public.leaderboard_snapshots(user_id, snapshot_date, rank, points)`; a daily `pg_cron` job that populates it.

- [ ] **Step 1: Add the points column and recompute trigger.**

```sql
alter table public.profiles
  add column points integer not null default 0;

create or replace function public.recompute_profile_points()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  affected_user uuid;
begin
  affected_user := coalesce(new.user_id, old.user_id);
  update public.profiles
  set points = (
    select count(*) * 10
    from public.reviews
    where user_id = affected_user
  )
  where id = affected_user;
  return coalesce(new, old);
end;
$$;

create trigger reviews_recompute_points
after insert or delete on public.reviews
for each row execute function public.recompute_profile_points();
```

- [ ] **Step 2: Create the snapshot table.**

```sql
create table public.leaderboard_snapshots (
  user_id uuid not null references public.profiles(id) on delete cascade,
  snapshot_date date not null,
  rank integer not null,
  points integer not null,
  primary key (user_id, snapshot_date)
);

alter table public.leaderboard_snapshots enable row level security;

create policy "Snapshots are publicly readable"
  on public.leaderboard_snapshots for select
  using (true);
```

(No insert/update/delete policy is added — the snapshot function below runs
`security definer` and bypasses RLS for writes; no client role can write to
this table.)

- [ ] **Step 3: Create the snapshot function and schedule it.**

```sql
create extension if not exists pg_cron;

create or replace function public.snapshot_leaderboard()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.leaderboard_snapshots (user_id, snapshot_date, rank, points)
  select
    id,
    current_date,
    row_number() over (order by points desc, created_at asc),
    points
  from public.profiles
  where points > 0
  on conflict (user_id, snapshot_date) do update
    set rank = excluded.rank, points = excluded.points;
end;
$$;

select cron.schedule(
  'snapshot-leaderboard-daily',
  '5 0 * * *',
  $$select public.snapshot_leaderboard()$$
);
```

- [ ] **Step 4: Verify.**

```sql
select column_name from information_schema.columns
where table_name = 'profiles' and column_name = 'points';
-- expect 1 row

select * from public.leaderboard_snapshots limit 1;
-- expect 0 rows (nothing has run yet) with no error

select public.snapshot_leaderboard();
select * from public.leaderboard_snapshots order by rank;
-- expect one row per profile with points > 0, ranked correctly
```

Run `get_advisors` (security): no new warnings beyond the pre-existing
`auth_leaked_password_protection`.

---

### Task 2: `LeaderboardEntry` model

**Files:**
- Create: `app/lib/domain/models/leaderboard_entry.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Produces: `LeaderboardEntry` (immutable), consumed by every later task.

- [ ] **Step 1: Write the failing test** — add to the test file, in a new
  top-level group before `group('Widgets', ...)`:

```dart
  group('LeaderboardEntry', () {
    test('carries rank, points, and an optional rank change', () {
      const withChange = LeaderboardEntry(
        userId: 'u1',
        name: 'Nadeesha',
        points: 860,
        rank: 2,
        rankChange: 3,
      );
      const withoutChange = LeaderboardEntry(
        userId: 'u2',
        name: 'New User',
        points: 10,
        rank: 40,
      );
      expect(withChange.rankChange, 3);
      expect(withoutChange.rankChange, isNull);
    });
  });
```

Add `import 'package:ceylon_review/domain/models/leaderboard_entry.dart';` to
the test file's import block.

- [ ] **Step 2: Run** `cd app && flutter test test/ceylon_review_test.dart`
  — expect FAIL (file doesn't exist).

- [ ] **Step 3: Implement.**

```dart
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
```

- [ ] **Step 4: Run** the test again — PASS. Run `flutter analyze` — "No
  issues found!".

- [ ] **Step 5: Commit.**

```bash
git add app/lib/domain/models/leaderboard_entry.dart app/test/ceylon_review_test.dart
git commit -m "Add LeaderboardEntry model"
```

---

### Task 3: `LeaderboardRepository` — interface, sample, Supabase

**Files:**
- Create: `app/lib/domain/repositories/leaderboard_repository.dart`
- Create: `app/lib/data/sample/sample_leaderboard_repository.dart`
- Create: `app/lib/data/supabase/supabase_leaderboard_repository.dart`
- Modify: `app/lib/application/repository_providers.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `LeaderboardEntry` (Task 2).
- Produces: `LeaderboardRepository.fetchLeaderboard()` /
  `.fetchMyRank(String userId)`; `leaderboardRepositoryProvider`.

- [ ] **Step 1: Write the failing test** (in a new group, after
  `SampleFavoritesRepository`'s group):

```dart
  group('SampleLeaderboardRepository', () {
    test('fetchLeaderboard returns entries ordered by points descending',
        () async {
      final repo = SampleLeaderboardRepository();
      final list = await repo.fetchLeaderboard();
      expect(list, isNotEmpty);
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].points, greaterThanOrEqualTo(list[i].points));
      }
      expect(list.first.rank, 1);
    });

    test('fetchMyRank finds the matching entry by userId', () async {
      final repo = SampleLeaderboardRepository();
      final list = await repo.fetchLeaderboard();
      final target = list[1];
      final mine = await repo.fetchMyRank(target.userId);
      expect(mine?.rank, target.rank);
    });

    test('fetchMyRank returns null for an unknown user', () async {
      final repo = SampleLeaderboardRepository();
      final mine = await repo.fetchMyRank('nobody');
      expect(mine, isNull);
    });
  });
```

Add `import 'package:ceylon_review/data/sample/sample_leaderboard_repository.dart';`
to the test file.

- [ ] **Step 2: Run** the suite — FAIL (files don't exist).

- [ ] **Step 3: Implement.**

Interface (`leaderboard_repository.dart`):

```dart
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
```

Sample (`sample_leaderboard_repository.dart`) — a few realistic entries with
some `rankChange` values populated so UI development doesn't depend on the
live snapshot job:

```dart
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
```

Supabase (`supabase_leaderboard_repository.dart`) — the full list ranks all
`points > 0` profiles; `rankChange` is computed by joining against each
user's most recent snapshot (there may be none) via a `distinct on` subquery:

```dart
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
```

`repository_providers.dart` — add, alongside the other providers:

```dart
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
    (ref) => SupabaseLeaderboardRepository(Supabase.instance.client));
```

with the matching import (`import '../data/supabase/supabase_leaderboard_repository.dart';`
and `import '../domain/repositories/leaderboard_repository.dart';`), placed
alphabetically among the existing imports/providers.

- [ ] **Step 4: Run** the suite + `flutter analyze` — pass/clean.

- [ ] **Step 5: Commit.**

```bash
git add app/lib/domain/repositories/leaderboard_repository.dart \
  app/lib/data/sample/sample_leaderboard_repository.dart \
  app/lib/data/supabase/supabase_leaderboard_repository.dart \
  app/lib/application/repository_providers.dart \
  app/test/ceylon_review_test.dart
git commit -m "Add LeaderboardRepository with Supabase and sample implementations"
```

---

### Task 4: Leaderboard providers + review-submit invalidation

**Files:**
- Create: `app/lib/application/leaderboard_provider.dart`
- Modify: `app/lib/application/reviews_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `leaderboardRepositoryProvider` (Task 3), `authProvider` (existing,
  `AppUser?`), `AppUser.id`.
- Produces: `leaderboardProvider` (`FutureProvider<List<LeaderboardEntry>>`),
  `myRankProvider` (`FutureProvider<LeaderboardEntry?>`).

- [ ] **Step 1: Write the failing test:**

```dart
  group('Leaderboard providers', () {
    test('leaderboardProvider returns the repository\'s ranked list',
        () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
      ]);
      addTearDown(container.dispose);

      final list = await container.read(leaderboardProvider.future);
      expect(list.first.name, 'Harsha W.');
    });

    test('myRankProvider is null when signed out', () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
        authProvider.overrideWith(() => _FakeAuthNotifier(null)),
      ]);
      addTearDown(container.dispose);

      final mine = await container.read(myRankProvider.future);
      expect(mine, isNull);
    });

    test('myRankProvider resolves the signed-in user\'s entry', () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'u-dilan', name: 'Dilan', email: 'd@example.com'))),
      ]);
      addTearDown(container.dispose);

      final mine = await container.read(myRankProvider.future);
      expect(mine?.rank, 3);
    });
  });
```

Add `import 'package:ceylon_review/application/leaderboard_provider.dart';`
to the test file's imports.

- [ ] **Step 2: Run** the suite — FAIL (`leaderboardProvider` undefined).

- [ ] **Step 3: Implement** `leaderboard_provider.dart`:

```dart
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
```

Then modify `reviews_provider.dart`'s `ReviewSubmitter.submit` to invalidate
the leaderboard after posting, in the same place the other invalidations
happen:

```dart
    _ref.invalidate(reviewsForPlaceProvider(placeId));
    _ref.invalidate(myReviewsProvider);
    // The backend recomputes the place's rating/review count on insert.
    _ref.invalidate(placeByIdProvider(placeId));
    _ref.invalidate(allPlacesProvider);
    _ref.invalidate(trendingPlacesProvider);
    _ref.invalidate(placesByCategoryProvider);
    // The backend also recomputes the reviewer's points via a trigger.
    _ref.invalidate(leaderboardProvider);
    _ref.invalidate(myRankProvider);
```

(Add `import 'leaderboard_provider.dart';` to `reviews_provider.dart`.)

- [ ] **Step 4: Run** the suite + `flutter analyze` — pass/clean.

- [ ] **Step 5: Commit.**

```bash
git add app/lib/application/leaderboard_provider.dart \
  app/lib/application/reviews_provider.dart \
  app/test/ceylon_review_test.dart
git commit -m "Add leaderboard providers and invalidate on review submit"
```

---

### Task 5: `LeaderboardScreen` — podium, your-rank card, animated list

**Files:**
- Create: `app/lib/presentation/screens/leaderboard/leaderboard_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `leaderboardProvider`, `myRankProvider` (Task 4),
  `LeaderboardEntry` (Task 2), `UserAvatar({required String name, double
  radius = 20})` (existing, `app/lib/presentation/widgets/user_avatar.dart`).
- Produces: `LeaderboardScreen` (no constructor params — consumed by Task 6's
  `AppShell`).

This is the largest task in the plan; it's still one task because the
podium, your-rank card, and list are not independently reviewable — they
share the same `AsyncValue` data and the podium/list split only makes sense
together.

- [ ] **Step 1: Write the failing widget tests** (add a new group inside
  `group('Widgets', ...)`, after the existing `AddPlaceScreen` test):

```dart
    testWidgets('LeaderboardScreen shows a podium for the top 3',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(SampleLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Harsha W.'), findsOneWidget);
      expect(find.text('Nadeesha'), findsOneWidget);
      expect(find.text('Dilan'), findsOneWidget);
      // Rank 4+ render in the list below the podium.
      expect(find.text('Sanduni P.'), findsOneWidget);
    });

    testWidgets('LeaderboardScreen shows an empty state with no reviews yet',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(_EmptyLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Be the first to post a review and claim #1!'),
          findsOneWidget);
    });

    testWidgets('LeaderboardScreen shows a your-rank card outside the top 3',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(SampleLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'u-kasun', name: 'Kasun R.', email: 'k@example.com'))),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('#5'), findsOneWidget);
    });
```

Add this helper class near the bottom of the test file, alongside
`_ThrowingPlacesRepository`:

```dart
class _EmptyLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async => [];

  @override
  Future<LeaderboardEntry?> fetchMyRank(String userId) async => null;
}
```

Add `import 'package:ceylon_review/presentation/screens/leaderboard/leaderboard_screen.dart';`
and `import 'package:ceylon_review/domain/repositories/leaderboard_repository.dart';`
to the test file's imports.

- [ ] **Step 2: Run** the suite — FAIL (`LeaderboardScreen` doesn't exist).

- [ ] **Step 3: Implement** `leaderboard_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/leaderboard_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/leaderboard_entry.dart';
import '../../widgets/user_avatar.dart';

/// Leaderboard: an animated podium for the top 3, the signed-in user's own
/// rank (if outside the top 3), and an animated list for everyone else.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final myRank = ref.watch(myRankProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Could not load the leaderboard.')),
        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyLeaderboard();
          }
          final top = entries.take(3).toList();
          final rest = entries.skip(3).toList();
          final myEntry = myRank.valueOrNull;
          final showMyRankCard = myEntry != null && myEntry.rank > 3;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              _Podium(top: top),
              const SizedBox(height: AppSpacing.lg),
              if (showMyRankCard) ...[
                _YourRankCard(
                  entry: myEntry,
                  pointsToNext: _pointsToNextRank(entries, myEntry),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              for (var i = 0; i < rest.length; i++)
                _LeaderboardRow(
                  entry: rest[i],
                  isMe: myEntry?.userId == rest[i].userId,
                  staggerIndex: i,
                ),
            ],
          );
        },
      ),
    );
  }

  /// Points needed to overtake the next-higher entry, or null if [mine] is
  /// already rank 1 or not found in [entries].
  int? _pointsToNextRank(List<LeaderboardEntry> entries, LeaderboardEntry mine) {
    final index = entries.indexWhere((e) => e.userId == mine.userId);
    if (index <= 0) return null;
    return entries[index - 1].points - mine.points + 1;
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Be the first to post a review and claim #1!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top});

  final List<LeaderboardEntry> top;

  LeaderboardEntry? _at(int rank) {
    for (final e in top) {
      if (e.rank == rank) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = _at(1);
    final second = _at(2);
    final third = _at(3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (second != null)
          Expanded(child: _PodiumSlot(entry: second, delayMs: 150)),
        if (first != null)
          Expanded(
              flex: 1, child: _PodiumSlot(entry: first, delayMs: 0, isFirst: true)),
        if (third != null)
          Expanded(child: _PodiumSlot(entry: third, delayMs: 300)),
      ],
    );
  }
}

class _PodiumSlot extends StatefulWidget {
  const _PodiumSlot({
    required this.entry,
    required this.delayMs,
    this.isFirst = false,
  });

  final LeaderboardEntry entry;
  final int delayMs;
  final bool isFirst;

  @override
  State<_PodiumSlot> createState() => _PodiumSlotState();
}

class _PodiumSlotState extends State<_PodiumSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _riseController;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _rise = CurvedAnimation(parent: _riseController, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _riseController.forward();
    });
  }

  @override
  void dispose() {
    _riseController.dispose();
    super.dispose();
  }

  Color _barColor(BuildContext context) {
    final tokens = Theme.of(context).extension<CeylonTokens>()!;
    return switch (widget.entry.rank) {
      1 => tokens.star,
      2 => const Color(0xFF9AA3AB),
      _ => const Color(0xFFCD8A4D),
    };
  }

  double _barHeight() => switch (widget.entry.rank) {
        1 => 92,
        2 => 66,
        _ => 46,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarRadius = widget.isFirst ? 42.0 : 32.0;

    return AnimatedBuilder(
      animation: _rise,
      builder: (context, child) => Opacity(
        opacity: _rise.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _rise.value) * 24),
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isFirst)
            const _BobbingCrown(),
          UserAvatar(name: widget.entry.name, radius: avatarRadius),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.entry.name,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          _CountUpPoints(target: widget.entry.points),
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            height: _barHeight(),
            width: 72,
            decoration: BoxDecoration(
              color: _barColor(context),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.md)),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '${widget.entry.rank}',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.surface),
            ),
          ),
        ],
      ),
    );
  }
}

class _BobbingCrown extends StatefulWidget {
  const _BobbingCrown();

  @override
  State<_BobbingCrown> createState() => _BobbingCrownState();
}

class _BobbingCrownState extends State<_BobbingCrown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * _controller.value),
        child: child,
      ),
      child: const Text('👑', style: TextStyle(fontSize: 26)),
    );
  }
}

class _CountUpPoints extends StatelessWidget {
  const _CountUpPoints({required this.target});

  final int target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        '${value.round()} pts',
        style: theme.textTheme.labelMedium?.copyWith(color: tokens.star),
      ),
    );
  }
}

class _YourRankCard extends StatelessWidget {
  const _YourRankCard({required this.entry, required this.pointsToNext});

  final LeaderboardEntry entry;
  final int? pointsToNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#${entry.rank}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You', style: theme.textTheme.titleSmall),
                if (pointsToNext != null)
                  Text('$pointsToNext pts to reach #${entry.rank - 1}',
                      style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text('${entry.points} pts',
              style: theme.textTheme.titleSmall?.copyWith(color: tokens.star)),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatefulWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isMe,
    required this.staggerIndex,
  });

  final LeaderboardEntry entry;
  final bool isMe;
  final int staggerIndex;

  @override
  State<_LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<_LeaderboardRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: 40 * widget.staggerIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = widget.entry.rankChange;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset((1 - _animation.value) * -14, 0),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: widget.isMe
            ? BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              )
            : null,
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('${widget.entry.rank}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium),
            ),
            const SizedBox(width: AppSpacing.sm),
            UserAvatar(name: widget.entry.name, radius: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                widget.isMe ? 'You' : widget.entry.name,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('${widget.entry.points} pts', style: theme.textTheme.labelMedium),
            if (change != null && change != 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                change > 0 ? '▲$change' : '▼${-change}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: change > 0
                      ? Colors.green.shade600
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run** the suite + `flutter analyze` — pass/clean.

- [ ] **Step 5: Commit.**

```bash
git add app/lib/presentation/screens/leaderboard/leaderboard_screen.dart app/test/ceylon_review_test.dart
git commit -m "Add LeaderboardScreen with podium and animated ranking list"
```

---

### Task 6: Wire the Leaderboard tab into the app shell

**Files:**
- Modify: `app/lib/presentation/shell/app_shell.dart`

**Interfaces:**
- Consumes: `LeaderboardScreen` (Task 5).

- [ ] **Step 1: Add the tab.** In `app_shell.dart`, add the import
  `import '../screens/leaderboard/leaderboard_screen.dart';`, insert
  `LeaderboardScreen()` as the 3rd entry in `_tabs` (after `MapScreen()`,
  before `WriteReviewScreen()`), and insert a matching
  `NavigationDestination` as the 3rd entry in `destinations` (after Map,
  before Post):

```dart
  static const _tabs = [
    HomeScreen(),
    MapScreen(),
    LeaderboardScreen(),
    WriteReviewScreen(),
    CategoryScreen(),
    ProfileScreen(),
  ];
```

```dart
          const NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranks',
          ),
```

placed between the existing Map and Post `NavigationDestination` entries.
(Label is "Ranks" rather than "Leaderboard" to keep nav labels short and
consistent with the app's single-word tab labels — Home, Map, Post, Feed,
Profile.)

- [ ] **Step 2: Run** `cd app && flutter test` (full suite — this file has
  no dedicated test, but confirm nothing else broke) and `flutter analyze` —
  pass/clean.

- [ ] **Step 3: Commit.**

```bash
git add app/lib/presentation/shell/app_shell.dart
git commit -m "Add Leaderboard tab to the app shell"
```

---

### Task 7: End-to-end verification and README update

**Files:**
- Modify: `README.md`, `app/README.md`

- [ ] **Step 1:** `cd app && flutter test` — all pass — and `flutter
  analyze` — clean.
- [ ] **Step 2: Manual on-device** (`flutter run` on the connected Android
  tablet): open the Ranks tab, confirm the podium renders with the crown
  bobbing on #1 and points counting up; post a review from a signed-in
  account, revisit the Ranks tab, confirm the account's points increased by
  10 and its position in the list/podium updated; if the account isn't yet
  in the top 3, confirm the "your rank" card shows with the correct "N pts
  to reach #M" text; confirm a brand-new account with 0 reviews does not
  appear in the list at all.
- [ ] **Step 3: Cross-check via Supabase MCP** (or the SQL editor if MCP
  tools are unavailable): `select id, name, points from public.profiles
  order by points desc;` matches what's shown in the app;
  `select public.snapshot_leaderboard();` then `select * from
  public.leaderboard_snapshots order by rank;` to confirm the cron function
  works correctly (the actual daily cron firing can't be verified same-day,
  but the function itself must run cleanly). `get_advisors` (security): no
  new warnings.
- [ ] **Step 4: READMEs.** `app/README.md` Features (after the Add a Place
  bullet):

```markdown
- **Leaderboard** — every review earns 10 points; a "Ranks" tab shows an animated podium for the top 3 and a live, all-time ranked list for everyone, with daily rank-change indicators
```

Root `README.md` Features (after the Add a Place bullet):

```markdown
- Leaderboard: reviews earn points, with an animated podium for the top 3 and daily rank-change indicators on a dedicated Ranks tab
```

- [ ] **Step 5: Commit.**

```bash
git add README.md app/README.md
git commit -m "Document Leaderboard feature in READMEs"
```
