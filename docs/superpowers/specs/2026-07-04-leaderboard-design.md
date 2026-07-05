# Leaderboard — Design

**Date:** 2026-07-04
**Status:** Approved by Harsha (in-session, including a mockup review via the
brainstorming visual companion)
**Depends on:** existing Supabase backend (`profiles`, `reviews` tables and
their rating trigger, per `docs/BACKEND_PLAN.md`).

## Goal

Every review a signed-in user posts earns them points. Anyone can open a
Leaderboard tab and see who's ranked where, with rank #1 shown prominently at
the top of a Duolingo-style podium, animated in an eye-catching way.

## Decisions (locked in during brainstorming)

- **Ranking model:** all-time points, live ranking. No weekly leagues, no
  daily reset — points only ever go up, and rank updates the instant someone
  posts a review. This is the simplest mental model ("climb the ranks over
  time") and needs no promotion/demotion logic.
- **Points:** flat **10 points per review**. No bonuses for photos or for
  Add-a-Place submissions in this phase (kept simple; can be revisited later).
- **Daily rank-change indicators:** kept, because they're the one place
  "daily" genuinely matters — a scheduled job snapshots each user's rank once
  a day, and the UI shows ▲/▼ versus that snapshot. Users with no snapshot yet
  (new accounts) show no arrow.
- **Placement:** a new 6th bottom-nav tab, order **Home, Map, Leaderboard,
  Post, Feed, Profile** — always one tap away, matching how central this
  feature is meant to be.
- **Visual treatment:** a podium for the top 3 (gold/silver/bronze bars,
  crown bobbing above #1, medal badges, count-up animation on points) plus a
  "Your rank" highlight card, then an animated list for everyone else with
  staggered entrance and per-row rank-change arrows. Approved via a live
  mockup (`.superpowers/brainstorm/.../leaderboard-v1.html`, not committed —
  brainstorm scratch output).
- **Avatars:** reuse the existing initials-based `UserAvatar` widget (colored
  circle + initials), just larger for the podium. The app has no profile
  photo upload feature; adding one is out of scope here.
- **Animations:** built with Flutter's own implicit animations
  (`TweenAnimationBuilder`, `AnimatedOpacity`/`AnimatedSlide` equivalents via
  simple `Tween` + `AnimationController`) — no new animation package. Keeps
  dependencies minimal per YAGNI; the mockup's staggered fade-slide-in and
  count-up effects are both achievable natively.

## Data model & backend

Migration on `public.profiles`:

```sql
alter table public.profiles
  add column points integer not null default 0;
```

New trigger function + trigger on `public.reviews`, mirroring the existing
places-rating trigger exactly:

```sql
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

Recomputing from `count(*) * 10` (rather than incrementing/decrementing) is
deliberately simple and self-healing — same trade-off the existing rating
trigger already makes, and at this app's data volume there's no performance
concern.

New table for daily rank snapshots:

```sql
create table public.leaderboard_snapshots (
  user_id uuid not null references public.profiles(id) on delete cascade,
  snapshot_date date not null,
  rank integer not null,
  points integer not null,
  primary key (user_id, snapshot_date)
);
```

Scheduled job (Supabase `pg_cron` extension, enabled via migration) running
once daily (00:05 UTC) to snapshot every profile's current rank:

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

RLS: `leaderboard_snapshots` is readable by everyone (`select` policy, no
`auth.uid()` restriction — ranks are public by design), writable by no one
from the client (only the security-definer scheduled function writes to it).
`profiles.points` requires no new RLS since it's read via the existing public
`select` policy on `profiles`; the trigger runs as `security definer` so
`update` on `points` never needs a client-facing write policy.

Run `get_advisors` (security) after migrating — no new warnings expected
beyond the pre-existing `auth_leaked_password_protection`.

## Domain & data layer

New `app/lib/domain/models/leaderboard_entry.dart`:

```dart
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

  /// Positive = moved up N spots since yesterday's snapshot, negative = down.
  /// Null if the user has no snapshot yet (e.g. joined today).
  final int? rankChange;
}
```

New `app/lib/domain/repositories/leaderboard_repository.dart`:

```dart
abstract interface class LeaderboardRepository {
  /// Ranked list of everyone with at least one review (points > 0), highest
  /// first. Profiles that have never posted a review are excluded entirely —
  /// a leaderboard of mostly-zero-point accounts isn't useful, and it keeps
  /// the empty-state logic simple (empty list = nobody has reviewed yet).
  Future<List<LeaderboardEntry>> fetchLeaderboard();

  /// The signed-in user's own entry, or null if they have zero points (i.e.
  /// haven't posted a review yet, so they don't have a rank to show).
  Future<LeaderboardEntry?> fetchMyRank(String userId);
}
```

Three-file pattern, matching every other repository in the app:

- `SupabaseLeaderboardRepository` — queries `profiles` ordered by `points
  desc, created_at asc` for the full list; joins against the latest
  `leaderboard_snapshots` row per user (via a `distinct on (user_id) ... order
  by snapshot_date desc` subquery) to compute `rankChange`.
- `SampleLeaderboardRepository` — in-memory, seeded with a handful of fake
  entries for offline/tests, with a couple of `rankChange` values populated so
  UI development doesn't depend on the live snapshot job.

`repository_providers.dart` gains `leaderboardRepositoryProvider`.

## Application layer

New `app/lib/application/leaderboard_provider.dart`:

```dart
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>(
    (ref) => ref.watch(leaderboardRepositoryProvider).fetchLeaderboard());

final myRankProvider = FutureProvider<LeaderboardEntry?>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Future.value(null);
  return ref.watch(leaderboardRepositoryProvider).fetchMyRank(user.id);
});
```

`AddReviewController`/`ReviewSubmitter` (wherever reviews are currently
posted) needs no changes — points update via the database trigger
automatically; the leaderboard providers are invalidated the same way places
providers are invalidated elsewhere (a `ref.invalidate` after posting a
review, or simply relying on `FutureProvider`'s natural refetch when the
Leaderboard tab is revisited, since points aren't shown live-pushed on the
Write Review screen itself).

## Presentation

New `app/lib/presentation/screens/leaderboard/leaderboard_screen.dart`:

- **Podium** (top 3, if at least 3 people have points — gracefully handles
  fewer): gold/silver/bronze bars ordered visually as 2nd–1st–3rd (matching
  the approved mockup), `UserAvatar` at a larger radius for each, a small
  medal badge, a crown icon above #1 with a gentle bobbing animation
  (`AnimationController` + `Tween<double>` looping), and points that count up
  from 0 on first build (`TweenAnimationBuilder<int>` over ~900ms with a
  cubic-out curve).
- **Your rank card:** shown below the podium when `myRankProvider` resolves
  to a non-null entry outside the top 3 (if the user is in the top 3, they
  already see themselves on the podium and this card is omitted). Shows
  current rank, points, and — if there's a next-higher entry — "N pts to
  reach #M".
- **List** for rank 4+ (or 1+ if fewer than 3 people have any points):
  staggered fade+slide-in entrance (40ms stagger per row, matching the
  existing card-entrance motion convention in
  `docs/superpowers/specs/` design-system notes), rank number, `UserAvatar`,
  name, points, and a small ▲/▼ + delta count when `rankChange != null`
  (green up, red/error down, matching the app's existing semantic colors).
- **Empty state:** if nobody has any points yet (fresh install), show a
  friendly "Be the first to post a review and claim #1!" message instead of
  an empty podium.
- **Loading/error states** follow the same `AsyncValue.when` pattern used
  throughout the app (spinner / inline error text).

`app_shell.dart`: add `LeaderboardScreen` as the 3rd tab (`Home, Map,
Leaderboard, Post, Feed, Profile`), with `Icons.leaderboard_outlined` /
`Icons.leaderboard_rounded` as the nav icon.

## Testing

- Unit: `SampleLeaderboardRepository` (returns the seeded ranked list;
  `fetchMyRank` finds the right entry), a small pure-Dart test for whatever
  ranking/sort helper is extracted (if any beyond what the repository already
  does).
- Widget: `LeaderboardScreen` renders the podium for a 3+-person sample list;
  renders the empty state when the sample list is empty; renders the "Your
  rank" card when the signed-in user's entry isn't in the top 3.
- Manual on-device: post a review, revisit the Leaderboard tab, confirm
  points/rank updated; cross-check `profiles.points` and
  `leaderboard_snapshots` via Supabase MCP `execute_sql`; confirm
  `get_advisors` shows no new warnings after the migration.

## Out of scope

- Weekly leagues / promotion-demotion tiers
- Points for photos or Add-a-Place submissions
- Real profile photo upload
- Push notifications about rank changes
- Any leaderboard filtering (e.g. "this week", "by category") — all-time only
