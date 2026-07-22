# Admin & Moderation Tools (Phase 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let any signed-in user report a bad review, and let an admin-role user delete reviews/places and resolve reports, all gated by Supabase RLS.

**Architecture:** A `profiles.role` column + `security definer` `is_admin()` SQL function back three new/changed RLS policies (reports insert/select/update, admin-bypass delete on reviews/places). The app adds a `reports` domain model/repository pair (mirroring every existing repository), a `delete()` method on the existing reviews/places repositories, a dedicated `isAdminProvider` (kept separate from `AppUser` since checking role requires an async DB read that doesn't fit the existing synchronous `AuthRepository.currentUser` getter), and three UI additions: a report button on `ReviewTile`, an admin-only delete button on `PlaceDetailScreen`, and an admin-only Moderation screen reachable from Profile.

**Tech Stack:** Flutter, flutter_riverpod, supabase_flutter, existing gen-l10n localization (new ARB keys added to all 3 locales), existing clean-architecture layering (domain / data / application / presentation).

Spec: `docs/superpowers/specs/2026-07-22-admin-moderation-design.md`

## Global Constraints

- Content moderation only this phase — no user banning/suspension (needs a service-role Edge Function, deferred).
- Reports are for reviews only, not places.
- No in-app admin-promotion UI — `profiles.role` is set manually via SQL.
- Admin status is exposed via a new `isAdminProvider` (`FutureProvider<bool>`), **not** a field on `AppUser` — an admin check requires a DB read that doesn't fit `AuthRepository.currentUser`'s synchronous signature (this is a deliberate deviation from the design spec's literal "add `isAdmin` to `AppUser`" wording, documented here since it changes the spec's stated wiring mechanism, not its behavior — every task below builds on `isAdminProvider`, not an `AppUser.isAdmin` field).
- Every new user-facing string goes through `context.l10n.<key>`, added to all three ARB files (`app/lib/l10n/app_en.arb`, `app_si.arb`, `app_ta.arb`), consistent with the existing localized app.
- `flutter analyze` clean, `flutter test` all green before every commit.
- Supabase migrations: apply manually via the Supabase SQL editor or MCP `execute_sql` (MCP tools have been unavailable in-session for prior phases — if unavailable again, tell the user explicitly and ask them to run the SQL, exactly as done for every prior backend migration on this repo), then verify with MCP `get_advisors` for no new RLS/security warnings.

---

### Task 1: Supabase migration — role, `is_admin()`, `reports` table, admin-bypass RLS

**Files:**
- Modify: `docs/BACKEND_PLAN.md` (append the new schema, matching how every prior migration was documented there)

**Interfaces:**
- Consumes: nothing.
- Produces: `public.profiles.role` (`text`, `'user'`/`'admin'`); `public.is_admin()` SQL function; `public.reports` table (`id`, `review_id`, `reporter_id`, `reason`, `note`, `status`, `created_at`) with RLS. Every later task's RLS-dependent behavior assumes this migration is live.

- [ ] **Step 1: Apply the migration**

Run this SQL via the Supabase SQL editor (project `ceylonreview`, ref `jrepeqykdgsckrlvujnt`) or MCP `execute_sql`:

```sql
alter table public.profiles
  add column role text not null default 'user'
    check (role in ('user', 'admin'));

create function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.reviews on delete cascade,
  reporter_id uuid not null references public.profiles on delete cascade,
  reason text not null check (reason in ('spam', 'inappropriate', 'fake', 'other')),
  note text,
  status text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  created_at timestamptz not null default now()
);
create index on public.reports (status, created_at desc);

alter table public.reports enable row level security;

create policy "Users can submit their own reports"
  on public.reports for insert
  with check (auth.uid() = reporter_id);

create policy "Admins can read all reports"
  on public.reports for select
  using (public.is_admin());

create policy "Admins can update report status"
  on public.reports for update
  using (public.is_admin());

create policy "Admins can delete any review"
  on public.reviews for delete
  using (public.is_admin());

create policy "Admins can delete any place"
  on public.places for delete
  using (public.is_admin());
```

- [ ] **Step 2: Verify**

Run MCP `get_advisors` (security category) — expect no new warnings. Run `select id, role from public.profiles limit 1;` to confirm the column exists with default `'user'`.

To test the admin path locally, manually promote your own test account:
```sql
update public.profiles set role = 'admin' where email = '<your-test-email>';
```

- [ ] **Step 3: Document in `docs/BACKEND_PLAN.md`**

Append a new section after the existing "## Database schema" section's SQL block (find the line `create index on public.reviews (user_id, created_at desc);` and insert after it, before the "Plus:" paragraph):

```sql

alter table public.profiles
  add column role text not null default 'user'
    check (role in ('user', 'admin'));

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.reviews on delete cascade,
  reporter_id uuid not null references public.profiles on delete cascade,
  reason text not null check (reason in ('spam', 'inappropriate', 'fake', 'other')),
  note text,
  status text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  created_at timestamptz not null default now()
);
create index on public.reports (status, created_at desc);
```

Add one bullet to the RLS-policies paragraph: "`is_admin()` security-definer function backs admin-bypass delete policies on `reviews`/`places`, and read/update policies on the new `reports` table (Phase 1 moderation)."

- [ ] **Step 4: Commit**

```bash
git add docs/BACKEND_PLAN.md
git commit -m "Add role/is_admin()/reports migration for Phase 1 moderation"
```

---

### Task 2: `Review.authorId` + delete methods on reviews/places repositories

**Files:**
- Modify: `app/lib/domain/models/review.dart`
- Modify: `app/lib/domain/repositories/reviews_repository.dart`
- Modify: `app/lib/data/supabase/supabase_reviews_repository.dart`
- Modify: `app/lib/data/sample/sample_reviews_repository.dart`
- Modify: `app/lib/domain/repositories/places_repository.dart`
- Modify: `app/lib/data/supabase/supabase_places_repository.dart`
- Modify: `app/lib/data/sample/sample_places_repository.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `Review.authorId` (`String`, required constructor param); `ReviewsRepository.delete(String reviewId)` (`Future<void>`); `PlacesRepository.delete(String placeId)` (`Future<void>`). Task 6 (report button visibility) uses `Review.authorId`; Task 5 (`ReportResolver`) uses `ReviewsRepository.delete`; Task 7 (admin delete-place button) uses `PlacesRepository.delete`.

- [ ] **Step 1: Write the failing tests**

Add to `app/test/ceylon_review_test.dart`, inside the existing `group('SampleReviewsRepository', ...)` block, a new test:

```dart
test('delete removes the review', () async {
  final repo = SampleReviewsRepository();
  final added = await repo.add(
    placeId: 'odel',
    authorName: 'Test User',
    rating: 3,
    text: 'Fine, nothing special.',
  );
  await repo.delete(added.id);
  final remaining = await repo.fetchForPlace('odel');
  expect(remaining.any((r) => r.id == added.id), isFalse);
});
```

Inside the existing `group('SamplePlacesRepository', ...)` block, a new test:

```dart
test('delete removes the place', () async {
  final repo = SamplePlacesRepository();
  final all = await repo.fetchAll();
  final target = all.first;
  await repo.delete(target.id);
  final remaining = await repo.fetchAll();
  expect(remaining.any((p) => p.id == target.id), isFalse);
});
```

Every existing `Review(...)` construction in this test file will fail to compile once `authorId` becomes a required field — do NOT fix those yet; that happens in Step 3 alongside the model change, in the same commit (this is a mechanical, codebase-wide rename-adjacent change, not a design decision).

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name "delete removes"`
Expected: FAIL — `delete` undefined on both repositories.

- [ ] **Step 3: Add `authorId` to `Review` and `delete()` to both repository pairs**

`app/lib/domain/models/review.dart` — add the field:

```dart
/// An immutable user review of a place.
class Review {
  const Review({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.authorName,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.photoUrls = const [],
  });

  final String id;
  final String placeId;

  /// The reviewer's user id (`profiles.id` / `auth.users.id`).
  final String authorId;
  final String authorName;
  final int rating; // 1..5 whole stars
  final String text;
  final DateTime createdAt;

  /// Public URLs of photos the reviewer attached (0–3).
  final List<String> photoUrls;
}
```

`app/lib/domain/repositories/reviews_repository.dart` — add `delete`:

```dart
abstract interface class ReviewsRepository {
  Future<List<Review>> fetchForPlace(String placeId);

  /// Reviews written by the signed-in user, newest first.
  Future<List<Review>> fetchMine();

  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
    List<String> photoUrls = const [],
  });

  /// Deletes a review by id. Requires either review ownership or admin
  /// role, enforced by RLS.
  Future<void> delete(String reviewId);
}
```

`app/lib/data/supabase/supabase_reviews_repository.dart` — add `authorId` to `_reviewFromRow` and add `add()`'s `user_id` insert value into the returned row already (it's already sent on insert; just also read it back), plus the new method:

```dart
  @override
  Future<void> delete(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
```

Update `_reviewFromRow`:
```dart
Review _reviewFromRow(Map<String, dynamic> row) => Review(
      id: row['id'] as String,
      placeId: row['place_id'] as String,
      authorId: row['user_id'] as String,
      authorName: row['author_name'] as String,
      rating: row['rating'] as int,
      text: row['text'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      photoUrls: (row['photo_urls'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
```

`app/lib/data/sample/sample_reviews_repository.dart` — thread `authorId` through `add()` (default to a fixed `'sample-user'` id, matching the id `SampleAuthRepository` already returns for signed-in sample sessions) and add `delete`:

```dart
  @override
  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
    List<String> photoUrls = const [],
  }) async {
    final review = Review(
      id: 'r${_nextId++}',
      placeId: placeId,
      authorId: 'sample-user',
      authorName: authorName,
      rating: rating,
      text: text,
      createdAt: DateTime.now(),
      photoUrls: photoUrls,
    );
    _reviews.add(review);
    _mine.add(review);
    return review;
  }

  @override
  Future<void> delete(String reviewId) async {
    _reviews.removeWhere((r) => r.id == reviewId);
    _mine.removeWhere((r) => r.id == reviewId);
  }
```

`app/lib/domain/repositories/places_repository.dart` — add `delete`:

```dart
  /// Deletes a place by id. Requires admin role, enforced by RLS.
  Future<void> delete(String id);
```

`app/lib/data/supabase/supabase_places_repository.dart` — add:

```dart
  @override
  Future<void> delete(String id) async {
    await _client.from('places').delete().eq('id', id);
  }
```

`app/lib/data/sample/sample_places_repository.dart` — add:

```dart
  @override
  Future<void> delete(String id) async {
    _places.removeWhere((p) => p.id == id);
  }
```

Now fix every existing `Review(...)` construction in `app/lib/data/sample/sample_data.dart` and `app/test/ceylon_review_test.dart` that doesn't pass `authorId` — add `authorId: 'sample-user'` (or a distinct fixed id per seeded review if the test asserts something id-specific; check each call site) to each one. Grep first: `grep -n "Review(" app/lib/data/sample/sample_data.dart app/test/ceylon_review_test.dart` and fix every constructor call.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd app && flutter analyze` (expect 0 issues) `&& flutter test` (expect ALL green — no count regression from before this task).

- [ ] **Step 5: Commit**

```bash
git add app/lib/domain app/lib/data app/test/ceylon_review_test.dart
git commit -m "Add Review.authorId and delete() to reviews/places repositories"
```

---

### Task 3: `Report` model + `ReportsRepository`

**Files:**
- Create: `app/lib/domain/models/report.dart`
- Create: `app/lib/domain/repositories/reports_repository.dart`
- Create: `app/lib/data/supabase/supabase_reports_repository.dart`
- Create: `app/lib/data/sample/sample_reports_repository.dart`
- Modify: `app/lib/application/repository_providers.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: nothing from Task 2 directly (reports reference reviews by id string, not by the `Review` type).
- Produces: `Report` (id, reviewId, reporterId, reason (`ReportReason`), note, status (`ReportStatus`), createdAt); `ReportsRepository` with `submit`, `fetchOpen`, `resolve`. Task 5's `reports_provider.dart` consumes this repository via `reportsRepositoryProvider`.

- [ ] **Step 1: Write the failing tests**

Add a new group to `app/test/ceylon_review_test.dart`, near the other `Sample*Repository` groups:

```dart
group('SampleReportsRepository', () {
  test('submit then fetchOpen returns it with status open', () async {
    final repo = SampleReportsRepository();
    await repo.submit(
      reviewId: 'r1',
      reporterId: 'user-1',
      reason: ReportReason.spam,
      note: null,
    );
    final open = await repo.fetchOpen();
    expect(open, hasLength(1));
    expect(open.first.reviewId, 'r1');
    expect(open.first.reason, ReportReason.spam);
    expect(open.first.status, ReportStatus.open);
  });

  test('resolve marks it actioned or dismissed and removes it from '
      'fetchOpen', () async {
    final repo = SampleReportsRepository();
    await repo.submit(
      reviewId: 'r1',
      reporterId: 'user-1',
      reason: ReportReason.fake,
      note: 'looks copy-pasted',
    );
    final id = (await repo.fetchOpen()).first.id;

    await repo.resolve(id, actioned: true);

    expect(await repo.fetchOpen(), isEmpty);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name SampleReportsRepository`
Expected: FAIL — `SampleReportsRepository`/`ReportReason`/`ReportStatus` undefined.

- [ ] **Step 3: Create the model and repository files**

`app/lib/domain/models/report.dart`:

```dart
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
```

`app/lib/domain/repositories/reports_repository.dart`:

```dart
import '../models/report.dart';

/// Reporting and moderating reviews.
abstract interface class ReportsRepository {
  Future<void> submit({
    required String reviewId,
    required String reporterId,
    required ReportReason reason,
    String? note,
  });

  /// Reports with status `open`, newest first. Admin-only per RLS.
  Future<List<Report>> fetchOpen();

  /// Marks a report `actioned` or `dismissed`. Admin-only per RLS.
  Future<void> resolve(String reportId, {required bool actioned});
}
```

`app/lib/data/sample/sample_reports_repository.dart`:

```dart
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
```

`app/lib/data/supabase/supabase_reports_repository.dart`:

```dart
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
```

Wire into `app/lib/application/repository_providers.dart` — add the import and provider, following the existing pattern exactly:

```dart
import '../data/supabase/supabase_reports_repository.dart';
import '../domain/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
    (ref) => SupabaseReportsRepository(Supabase.instance.client));
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 5: Commit**

```bash
git add app/lib/domain/models/report.dart app/lib/domain/repositories/reports_repository.dart app/lib/data/supabase/supabase_reports_repository.dart app/lib/data/sample/sample_reports_repository.dart app/lib/application/repository_providers.dart app/test/ceylon_review_test.dart
git commit -m "Add Report model and ReportsRepository (sample + Supabase)"
```

---

### Task 4: `isAdminProvider`

**Files:**
- Modify: `app/lib/domain/repositories/auth_repository.dart`
- Modify: `app/lib/data/supabase/supabase_auth_repository.dart`
- Modify: `app/lib/data/sample/sample_auth_repository.dart`
- Modify: `app/lib/application/auth_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `authProvider` (existing, `NotifierProvider<AuthNotifier, AppUser?>`).
- Produces: `isAdminProvider` — `FutureProvider<bool>`. Task 7 (admin delete-place button) and Task 8 (Profile Moderation row) both gate their UI on `ref.watch(isAdminProvider).valueOrNull ?? false`.

- [ ] **Step 1: Write the failing test**

Add to `app/test/ceylon_review_test.dart`, near the other provider-only tests:

```dart
group('isAdminProvider', () {
  test('false when signed out', () async {
    final container = ProviderContainer(overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(isAdminProvider.future), isFalse);
  });
});
```

(A signed-in-admin-is-true case is exercised at the widget level in Tasks 7/8 via a direct `isAdminProvider.overrideWith(...)`, since `SampleAuthRepository`/`SampleReportsRepository` have no notion of role — there is deliberately no "signed in, is admin" path through the real repositories in this sample-backed test, only through the provider override.)

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name isAdminProvider`
Expected: FAIL — `isAdminProvider` undefined.

- [ ] **Step 3: Add `isCurrentUserAdmin()` to the repository and the provider**

`app/lib/domain/repositories/auth_repository.dart` — add to the interface:

```dart
  /// Whether the currently signed-in user has the `admin` role. False when
  /// signed out.
  Future<bool> isCurrentUserAdmin();
```

`app/lib/data/supabase/supabase_auth_repository.dart` — add:

```dart
  @override
  Future<bool> isCurrentUserAdmin() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final row = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return row?['role'] == 'admin';
  }
```

`app/lib/data/sample/sample_auth_repository.dart` — add:

```dart
  @override
  Future<bool> isCurrentUserAdmin() async => false;
```

`app/lib/application/auth_provider.dart` — add below the existing providers:

```dart
/// Whether the signed-in user is an admin. False when signed out.
final isAdminProvider = FutureProvider<bool>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return Future.value(false);
  return ref.watch(authRepositoryProvider).isCurrentUserAdmin();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 5: Commit**

```bash
git add app/lib/domain/repositories/auth_repository.dart app/lib/data/supabase/supabase_auth_repository.dart app/lib/data/sample/sample_auth_repository.dart app/lib/application/auth_provider.dart app/test/ceylon_review_test.dart
git commit -m "Add isAdminProvider backed by AuthRepository.isCurrentUserAdmin"
```

---

### Task 5: `reports_provider.dart` — submit and resolve reports

**Files:**
- Create: `app/lib/application/reports_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `reportsRepositoryProvider` (Task 3), `reviewsRepositoryProvider.delete` (Task 2), `authProvider` (existing).
- Produces: `openReportsProvider` (`FutureProvider<List<Report>>`); `reportSubmitterProvider` exposing a `ReportSubmitter` with `submit({required String reviewId, required ReportReason reason, String? note})`; `reportResolverProvider` exposing a `ReportResolver` with `resolve(String reportId, {required bool actioned})`. Task 6 (report button) uses `reportSubmitterProvider`; Task 8 (ModerationScreen) uses `openReportsProvider` and `reportResolverProvider`.

- [ ] **Step 1: Write the failing tests**

Add to `app/test/ceylon_review_test.dart`:

```dart
group('ReportSubmitter', () {
  test('submit adds a report as the signed-in user', () async {
    final reportsRepo = SampleReportsRepository();
    final container = ProviderContainer(overrides: [
      reportsRepositoryProvider.overrideWithValue(reportsRepo),
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'user-1', name: 'Test User', email: 't@example.com'))),
    ]);
    addTearDown(container.dispose);

    await container.read(reportSubmitterProvider).submit(
          reviewId: 'r1',
          reason: ReportReason.spam,
          note: 'obvious spam',
        );

    final open = await reportsRepo.fetchOpen();
    expect(open, hasLength(1));
    expect(open.first.reporterId, 'user-1');
  });

  test('submit throws when signed out', () async {
    final container = ProviderContainer(overrides: [
      reportsRepositoryProvider.overrideWithValue(SampleReportsRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
    ]);
    addTearDown(container.dispose);

    expect(
      () => container
          .read(reportSubmitterProvider)
          .submit(reviewId: 'r1', reason: ReportReason.other),
      throwsStateError,
    );
  });
});

group('ReportResolver', () {
  test('resolve with actioned: true deletes the review and resolves the '
      'report', () async {
    final reviewsRepo = SampleReviewsRepository();
    final added = await reviewsRepo.add(
      placeId: 'odel',
      authorName: 'Someone',
      rating: 1,
      text: 'This is spam content here.',
    );
    final reportsRepo = SampleReportsRepository();
    await reportsRepo.submit(
      reviewId: added.id,
      reporterId: 'user-2',
      reason: ReportReason.spam,
    );
    final reportId = (await reportsRepo.fetchOpen()).first.id;

    final container = ProviderContainer(overrides: [
      reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
      reportsRepositoryProvider.overrideWithValue(reportsRepo),
    ]);
    addTearDown(container.dispose);

    await container
        .read(reportResolverProvider)
        .resolve(reportId, actioned: true);

    expect(await reportsRepo.fetchOpen(), isEmpty);
    expect(await reviewsRepo.fetchForPlace('odel'), isEmpty);
  });

  test('resolve with actioned: false only dismisses the report', () async {
    final reviewsRepo = SampleReviewsRepository();
    final added = await reviewsRepo.add(
      placeId: 'odel',
      authorName: 'Someone',
      rating: 4,
      text: 'A perfectly fine review, wrongly reported.',
    );
    final reportsRepo = SampleReportsRepository();
    await reportsRepo.submit(
      reviewId: added.id,
      reporterId: 'user-2',
      reason: ReportReason.other,
    );
    final reportId = (await reportsRepo.fetchOpen()).first.id;

    final container = ProviderContainer(overrides: [
      reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
      reportsRepositoryProvider.overrideWithValue(reportsRepo),
    ]);
    addTearDown(container.dispose);

    await container
        .read(reportResolverProvider)
        .resolve(reportId, actioned: false);

    expect(await reportsRepo.fetchOpen(), isEmpty);
    expect(await reviewsRepo.fetchForPlace('odel'), hasLength(1));
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name ReportSubmitter --plain-name ReportResolver`
Expected: FAIL — `reportSubmitterProvider`/`reportResolverProvider` undefined.

- [ ] **Step 3: Create `reports_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/report.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';
import 'reviews_provider.dart';

final openReportsProvider = FutureProvider<List<Report>>(
    (ref) => ref.watch(reportsRepositoryProvider).fetchOpen());

/// Submits a report as the signed-in user.
class ReportSubmitter {
  ReportSubmitter(this._ref);

  final Ref _ref;

  Future<void> submit({
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) async {
    final user = _ref.read(authProvider);
    if (user == null) {
      throw StateError('You must be signed in to report a review.');
    }
    await _ref.read(reportsRepositoryProvider).submit(
          reviewId: reviewId,
          reporterId: user.id,
          reason: reason,
          note: note,
        );
    _ref.invalidate(openReportsProvider);
  }
}

final reportSubmitterProvider = Provider((ref) => ReportSubmitter(ref));

/// Resolves a report: `actioned` deletes the underlying review, `dismissed`
/// leaves it untouched. Either way the report's status is updated.
class ReportResolver {
  ReportResolver(this._ref);

  final Ref _ref;

  Future<void> resolve(String reportId, {required bool actioned}) async {
    if (actioned) {
      final reports = await _ref.read(reportsRepositoryProvider).fetchOpen();
      final report = reports.firstWhere((r) => r.id == reportId);
      await _ref.read(reviewsRepositoryProvider).delete(report.reviewId);
    }
    await _ref
        .read(reportsRepositoryProvider)
        .resolve(reportId, actioned: actioned);
    _ref.invalidate(openReportsProvider);
  }
}

final reportResolverProvider = Provider((ref) => ReportResolver(ref));
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 5: Commit**

```bash
git add app/lib/application/reports_provider.dart app/test/ceylon_review_test.dart
git commit -m "Add ReportSubmitter and ReportResolver providers"
```

---

### Task 6: Report button on `ReviewTile`

**Files:**
- Modify: `app/lib/presentation/widgets/review_tile.dart`
- Modify: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_si.arb`, `app/lib/l10n/app_ta.arb`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `Review.authorId` (Task 2), `reportSubmitterProvider` (Task 5), `authProvider` (existing).
- Produces: nothing new — this is the report-submission UI.

- [ ] **Step 1: Add the new ARB keys**

Add to `app/lib/l10n/app_en.arb` (alongside the existing keys, anywhere in the flat list):
```json
  "reportReview": "Report",
  "reportThisReview": "Report this review",
  "reportReasonSpam": "Spam",
  "reportReasonInappropriate": "Inappropriate",
  "reportReasonFake": "Fake or misleading",
  "reportReasonOther": "Other",
  "reportNoteOptional": "Additional details (optional)",
  "submitReport": "Submit report",
  "reportSubmittedThankYou": "Report submitted. Thank you for helping keep reviews trustworthy.",
  "couldNotSubmitReport": "Could not submit the report. Please try again.",
```

Add to `app/lib/l10n/app_si.arb`:
```json
  "reportReview": "වාර්තා කරන්න",
  "reportThisReview": "මෙම සමාලෝචනය වාර්තා කරන්න",
  "reportReasonSpam": "ස්පෑම්",
  "reportReasonInappropriate": "නුසුදුසුයි",
  "reportReasonFake": "ව්‍යාජ හෝ නොමඟ යවන",
  "reportReasonOther": "වෙනත්",
  "reportNoteOptional": "අමතර විස්තර (අත්‍යවශ්‍ය නොවේ)",
  "submitReport": "වාර්තාව යවන්න",
  "reportSubmittedThankYou": "වාර්තාව යවන ලදී. සමාලෝචන විශ්වාසදායක තබා ගැනීමට උදව් කිරීම ගැන ස්තූතියි.",
  "couldNotSubmitReport": "වාර්තාව යැවිය නොහැකි විය. නැවත උත්සාහ කරන්න.",
```

Add to `app/lib/l10n/app_ta.arb`:
```json
  "reportReview": "புகார் செய்",
  "reportThisReview": "இந்த விமர்சனத்தை புகார் செய்யுங்கள்",
  "reportReasonSpam": "ஸ்பேம்",
  "reportReasonInappropriate": "பொருத்தமற்றது",
  "reportReasonFake": "போலி அல்லது தவறான தகவல்",
  "reportReasonOther": "மற்றவை",
  "reportNoteOptional": "கூடுதல் விவரங்கள் (விருப்பம்)",
  "submitReport": "புகாரை சமர்ப்பிக்கவும்",
  "reportSubmittedThankYou": "புகார் சமர்ப்பிக்கப்பட்டது. விமர்சனங்களை நம்பகமானதாக வைத்திருக்க உதவியதற்கு நன்றி.",
  "couldNotSubmitReport": "புகாரை சமர்ப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.",
```

Run: `cd app && flutter gen-l10n` — regenerates `app/lib/l10n/generated/`.

- [ ] **Step 2: Write the failing test**

Add to the `group('Widgets', ...)` block in `app/test/ceylon_review_test.dart`:

```dart
testWidgets('ReviewTile shows a report button for others\' reviews and '
    'submits a report', (tester) async {
  final review = Review(
    id: 'r1',
    placeId: 'odel',
    authorId: 'other-user',
    authorName: 'Someone Else',
    rating: 3,
    text: 'An okay experience overall.',
    createdAt: DateTime(2026, 1, 1),
  );
  final reportsRepo = SampleReportsRepository();

  await tester.pumpWidget(themed(
    ReviewTile(review: review),
    overrides: [
      reportsRepositoryProvider.overrideWithValue(reportsRepo),
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'user-1', name: 'Test User', email: 't@example.com'))),
    ],
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.flag_outlined));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Spam'));
  await tester.tap(find.text('Submit report'));
  await tester.pumpAndSettle();

  final open = await reportsRepo.fetchOpen();
  expect(open, hasLength(1));
  expect(open.first.reason, ReportReason.spam);
});

testWidgets('ReviewTile hides the report button for the current user\'s '
    'own review', (tester) async {
  final review = Review(
    id: 'r1',
    placeId: 'odel',
    authorId: 'user-1',
    authorName: 'Test User',
    rating: 5,
    text: 'My own great review of this place.',
    createdAt: DateTime(2026, 1, 1),
  );

  await tester.pumpWidget(themed(
    ReviewTile(review: review),
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'user-1', name: 'Test User', email: 't@example.com'))),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.flag_outlined), findsNothing);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name ReviewTile`
Expected: FAIL — no report button exists yet.

- [ ] **Step 4: Add the report button and sheet to `ReviewTile`**

Convert `ReviewTile` from `StatelessWidget` to `ConsumerWidget` (add `import 'package:flutter_riverpod/flutter_riverpod.dart';`, `import '../../application/auth_provider.dart';`, `import '../../application/reports_provider.dart';`, `import '../../domain/models/report.dart';`, `import '../../core/l10n_ext.dart';`) and change the class/build signatures:

```dart
class ReviewTile extends ConsumerWidget {
  const ReviewTile({super.key, required this.review});

  final Review review;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final d = review.createdAt;
    final date = '${_months[d.month - 1]} ${d.day}, ${d.year}';
    final currentUserId = ref.watch(authProvider)?.id;
    final isOwnReview = currentUserId != null && currentUserId == review.authorId;
```

In the header `Row` (author avatar / name / date / rating stars), add the report button after the `RatingStars` widget, still inside that same `Row`'s `children`:

```dart
              RatingStars(rating: review.rating.toDouble(), size: 14),
              if (!isOwnReview) ...[
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  tooltip: context.l10n.reportThisReview,
                  onPressed: () => _showReportSheet(context, ref),
                ),
              ],
```

Add the sheet as a private method on the class (after `build`):

```dart
  void _showReportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ReportSheet(reviewId: review.id),
    );
  }
```

Add the sheet widget at the bottom of the file, after the `ReviewTile` class:

```dart
class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(reportSubmitterProvider).submit(
            reviewId: widget.reviewId,
            reason: _reason!,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.reportSubmittedThankYou)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotSubmitReport)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = {
      ReportReason.spam: context.l10n.reportReasonSpam,
      ReportReason.inappropriate: context.l10n.reportReasonInappropriate,
      ReportReason.fake: context.l10n.reportReasonFake,
      ReportReason.other: context.l10n.reportReasonOther,
    };
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.gutter,
        right: AppSpacing.gutter,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.reportThisReview,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final entry in reasons.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: _reason == entry.key,
                  onSelected: (_) => setState(() => _reason = entry.key),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            decoration:
                InputDecoration(labelText: context.l10n.reportNoteOptional),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: (_reason == null || _busy) ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(context.l10n.submitReport),
          ),
        ],
      ),
    );
  }
}
```

Note: `AppSpacing` is already imported at the top of this file.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 6: Commit**

```bash
git add app/lib/presentation/widgets/review_tile.dart app/lib/l10n app/test/ceylon_review_test.dart
git commit -m "Add report button and sheet to ReviewTile"
```

---

### Task 7: Admin delete-place button on `PlaceDetailScreen`

**Files:**
- Modify: `app/lib/presentation/screens/place_detail/place_detail_screen.dart`
- Modify: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_si.arb`, `app/lib/l10n/app_ta.arb`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `isAdminProvider` (Task 4), `placesRepositoryProvider.delete` (Task 2).
- Produces: nothing new.

- [ ] **Step 1: Add ARB keys**

`app_en.arb`:
```json
  "deletePlace": "Delete place",
  "deletePlaceConfirmTitle": "Delete this place?",
  "deletePlaceConfirmBody": "This permanently removes the place and all its reviews. This cannot be undone.",
  "couldNotDeletePlace": "Could not delete the place. Please try again.",
```

`app_si.arb`:
```json
  "deletePlace": "ස්ථානය මකන්න",
  "deletePlaceConfirmTitle": "මෙම ස්ථානය මකන්නද?",
  "deletePlaceConfirmBody": "මෙය ස්ථානය සහ එහි සියලුම සමාලෝචන ස්ථිරවම ඉවත් කරයි. මෙය ආපසු හැරවිය නොහැක.",
  "couldNotDeletePlace": "ස්ථානය මකා දැමිය නොහැකි විය. නැවත උත්සාහ කරන්න.",
```

`app_ta.arb`:
```json
  "deletePlace": "இடத்தை நீக்கு",
  "deletePlaceConfirmTitle": "இந்த இடத்தை நீக்கவா?",
  "deletePlaceConfirmBody": "இது இடத்தையும் அதன் அனைத்து விமர்சனங்களையும் நிரந்தரமாக அகற்றும். இதை மீட்க முடியாது.",
  "couldNotDeletePlace": "இடத்தை நீக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.",
```

Run: `cd app && flutter gen-l10n`.

- [ ] **Step 2: Write the failing test**

Add to `group('Widgets', ...)`:

```dart
testWidgets('PlaceDetailScreen shows a delete button for admins and '
    'deletes the place on confirm', (tester) async {
  final placesRepo = SamplePlacesRepository();
  final place = (await placesRepo.fetchAll()).first;

  await tester.pumpWidget(themed(
    PlaceDetailScreen(placeId: place.id),
    overrides: [
      placesRepositoryProvider.overrideWithValue(placesRepo),
      reviewsRepositoryProvider
          .overrideWithValue(SampleReviewsRepository(seed: [])),
      favoritesRepositoryProvider
          .overrideWithValue(SampleFavoritesRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'admin-1', name: 'Admin', email: 'a@example.com'))),
      isAdminProvider.overrideWith((ref) => Future.value(true)),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

  await tester.tap(find.byIcon(Icons.delete_outline_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete place'));
  await tester.pumpAndSettle();

  expect(await placesRepo.fetchById(place.id), isNull);
});

testWidgets('PlaceDetailScreen hides the delete button for non-admins',
    (tester) async {
  final placesRepo = SamplePlacesRepository();
  final place = (await placesRepo.fetchAll()).first;

  await tester.pumpWidget(themed(
    PlaceDetailScreen(placeId: place.id),
    overrides: [
      placesRepositoryProvider.overrideWithValue(placesRepo),
      reviewsRepositoryProvider
          .overrideWithValue(SampleReviewsRepository(seed: [])),
      favoritesRepositoryProvider
          .overrideWithValue(SampleFavoritesRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
      isAdminProvider.overrideWith((ref) => Future.value(false)),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name "PlaceDetailScreen shows a delete"`
Expected: FAIL — no delete button exists yet.

- [ ] **Step 4: Add the button**

In `app/lib/presentation/screens/place_detail/place_detail_screen.dart`, add imports: `import '../../../application/auth_provider.dart';` and `import '../../../core/l10n_ext.dart';` is already imported. In `_PlaceDetailBody.build`, add below the existing `isFavorite` line:

```dart
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;
```

In the `Row` that already contains the district text and favorite `IconButton` (right after that `IconButton`'s closing), add:

```dart
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: theme.colorScheme.error,
                          onPressed: () => _confirmDeletePlace(context, ref),
                        ),
```

Add a private top-level function (after the `_PlaceDetailBody` class, before `_CircleBackButton`):

```dart
Future<void> _confirmDeletePlace(BuildContext context, WidgetRef ref) async {
  final place = ref.read(placeByIdProvider(ref
          .read(placeByIdProvider.notifier as dynamic) is Never
      ? ''
      : ''));
  // placeId is available via the enclosing widget; simplest is to read it
  // from the already-resolved place passed into _PlaceDetailBody instead.
}
```

Actually pass the place id directly rather than re-reading a provider — replace the call site above with `onPressed: () => _confirmDeletePlace(context, ref, place.id),` and define:

```dart
Future<void> _confirmDeletePlace(
    BuildContext context, WidgetRef ref, String placeId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.deletePlaceConfirmTitle),
      content: Text(context.l10n.deletePlaceConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(context.l10n.deletePlace),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref.read(placesRepositoryProvider).delete(placeId);
    ref.invalidate(allPlacesProvider);
    ref.invalidate(placesByCategoryProvider);
    ref.invalidate(trendingPlacesProvider);
    if (context.mounted) Navigator.of(context).maybePop();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotDeletePlace)),
      );
    }
  }
}
```

(Delete the placeholder `_confirmDeletePlace` draft above if you wrote it first — only the final version with the `placeId` parameter should remain in the file.)

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 6: Commit**

```bash
git add app/lib/presentation/screens/place_detail/place_detail_screen.dart app/lib/l10n app/test/ceylon_review_test.dart
git commit -m "Add admin delete-place button to PlaceDetailScreen"
```

---

### Task 8: Profile "Moderation" row + `ModerationScreen`

**Files:**
- Create: `app/lib/presentation/screens/moderation/moderation_screen.dart`
- Modify: `app/lib/presentation/screens/profile/profile_screen.dart`
- Modify: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_si.arb`, `app/lib/l10n/app_ta.arb`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `isAdminProvider` (Task 4), `openReportsProvider`/`reportResolverProvider` (Task 5), `reviewsForPlaceProvider`/`ReviewTile` (existing).
- Produces: nothing new — final UI task for this phase.

- [ ] **Step 1: Add ARB keys**

`app_en.arb`:
```json
  "moderation": "Moderation",
  "noOpenReports": "No open reports.",
  "couldNotLoadReports": "Could not load reports.",
  "deleteReview": "Delete review",
  "dismiss": "Dismiss",
```

`app_si.arb`:
```json
  "moderation": "මධ්‍යස්ථභාවකරණය",
  "noOpenReports": "විවෘත වාර්තා නැත.",
  "couldNotLoadReports": "වාර්තා පූරණය කළ නොහැකි විය.",
  "deleteReview": "සමාලෝචනය මකන්න",
  "dismiss": "ඉවත් කරන්න",
```

`app_ta.arb`:
```json
  "moderation": "நடத்தை மேற்பார்வை",
  "noOpenReports": "திறந்த புகார்கள் இல்லை.",
  "couldNotLoadReports": "புகார்களை ஏற்ற முடியவில்லை.",
  "deleteReview": "விமர்சனத்தை நீக்கு",
  "dismiss": "நிராகரி",
```

Run: `cd app && flutter gen-l10n`.

- [ ] **Step 2: Write the failing tests**

Add to `group('Widgets', ...)`:

```dart
testWidgets('Profile shows the Moderation row only for admins',
    (tester) async {
  await tester.pumpWidget(themed(
    const ProfileScreen(),
    overrides: [
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'admin-1', name: 'Admin', email: 'a@example.com'))),
      isAdminProvider.overrideWith((ref) => Future.value(true)),
      myReviewsProvider.overrideWith((ref) => Future.value(const [])),
      myFavoriteIdsProvider
          .overrideWith(() => _EmptyFavoriteIdsNotifier()),
      allPlacesProvider.overrideWith((ref) => Future.value(const [])),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.text('Moderation'), findsOneWidget);
});

testWidgets('ModerationScreen lists an open report and deletes the '
    'review on Delete', (tester) async {
  final reviewsRepo = SampleReviewsRepository();
  final review = await reviewsRepo.add(
    placeId: 'odel',
    authorName: 'Reported User',
    rating: 1,
    text: 'This looks like spam content.',
  );
  final reportsRepo = SampleReportsRepository();
  await reportsRepo.submit(
    reviewId: review.id,
    reporterId: 'user-2',
    reason: ReportReason.spam,
  );

  await tester.pumpWidget(themed(
    const ModerationScreen(),
    overrides: [
      reportsRepositoryProvider.overrideWithValue(reportsRepo),
      reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.text('Reported User'), findsOneWidget);

  await tester.tap(find.text('Delete review'));
  await tester.pumpAndSettle();

  expect(find.text('No open reports.'), findsOneWidget);
  expect(await reviewsRepo.fetchForPlace('odel'), isEmpty);
});
```

Check the test file for an existing fake favorites-ids notifier pattern before adding `_EmptyFavoriteIdsNotifier` — search for how `myFavoriteIdsProvider` is overridden in the existing `'PlaceCard heart toggles favorite state'` test and other `ProfileScreen`-adjacent tests (it's likely overridden via `favoritesRepositoryProvider.overrideWithValue(...)` rather than a notifier override, since `myFavoriteIdsProvider` is itself a `Notifier` reading through `favoritesRepositoryProvider`). If so, replace the `myFavoriteIdsProvider.overrideWith(...)` line above with `favoritesRepositoryProvider.overrideWithValue(SampleFavoritesRepository())` instead, matching the established pattern.

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name "Moderation row" --plain-name ModerationScreen`
Expected: FAIL — `ModerationScreen`/Moderation row don't exist yet.

- [ ] **Step 4: Create `ModerationScreen`**

`app/lib/presentation/screens/moderation/moderation_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/reports_provider.dart';
import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/report.dart';

/// Admin-only: lists open reports with Delete-review / Dismiss actions.
class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(openReportsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.moderation)),
      body: reports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text(context.l10n.couldNotLoadReports)),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(context.l10n.noOpenReports));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            itemCount: list.length,
            separatorBuilder: (_, __) =>
                const Divider(height: AppSpacing.xl),
            itemBuilder: (_, i) => _ReportRow(report: list[i]),
          );
        },
      ),
    );
  }
}

class _ReportRow extends ConsumerWidget {
  const _ReportRow({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review ${report.reviewId}', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(_reasonLabel(context, report.reason)),
        if (report.note != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(report.note!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            TextButton(
              onPressed: () => ref
                  .read(reportResolverProvider)
                  .resolve(report.id, actioned: true),
              child: Text(context.l10n.deleteReview),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => ref
                  .read(reportResolverProvider)
                  .resolve(report.id, actioned: false),
              child: Text(context.l10n.dismiss),
            ),
          ],
        ),
      ],
    );
  }

  String _reasonLabel(BuildContext context, ReportReason reason) =>
      switch (reason) {
        ReportReason.spam => context.l10n.reportReasonSpam,
        ReportReason.inappropriate => context.l10n.reportReasonInappropriate,
        ReportReason.fake => context.l10n.reportReasonFake,
        ReportReason.other => context.l10n.reportReasonOther,
      };
}
```

Note: this row shows the raw review id and no author/text snippet, since `Report` doesn't carry denormalized review content (only `reviewId`) and fetching the full `Review` per report is unnecessary for this phase's scope — an admin can already see review content and delete it directly from wherever the review is shown in the app if more context is needed. Do not add a join/denormalization for this; it's out of scope.

- [ ] **Step 5: Add the Profile row**

In `app/lib/presentation/screens/profile/profile_screen.dart`, add imports:
```dart
import '../../../application/reports_provider.dart' show ModerationScreen; // WRONG — remove this line, see below
```

That import is wrong — `ModerationScreen` lives in its own file. Use instead:
```dart
import '../moderation/moderation_screen.dart';
```

Add `final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;` alongside the other `ref.watch(...)` lines at the top of `build`, and add `import '../../../application/auth_provider.dart';` (check it isn't already imported — it likely is, since `authProvider` is already used in this file; if so just add the new watch line, no new import needed).

Insert a new `ListTile` right after the existing "Language" `ListTile` and before the `const Divider(height: 1)` that follows it, gated on `isAdmin`:

```dart
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.shield_rounded),
                title: Text(context.l10n.moderation),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModerationScreen()),
                ),
              ),
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `cd app && flutter analyze && flutter test`
Expected: 0 issues; all green.

- [ ] **Step 7: Commit**

```bash
git add app/lib/presentation/screens/moderation app/lib/presentation/screens/profile/profile_screen.dart app/lib/l10n app/test/ceylon_review_test.dart
git commit -m "Add admin-only Moderation row and screen to Profile"
```

---

### Task 9: Final verification pass + README update

**Files:**
- Modify: `app/README.md`
- Modify: `README.md` (root, if it still lists app features)

**Interfaces:** Consumes everything prior. Produces nothing new.

- [ ] **Step 1: Full verification**

Run: `cd app && flutter analyze` → 0 issues. `flutter test` → ALL green; report the final count.

Grep for any remaining hardcoded English strings this phase's UI files introduced: `grep -rnE "Text\('[A-Z]" app/lib/presentation/screens/moderation app/lib/presentation/screens/place_detail app/lib/presentation/widgets/review_tile.dart | grep -v "l10n"` — every hit should be non-UI (e.g. a debug label) or already flagged as an intentional exception; fix any real leftover the same way prior localization work did (map to an existing key or add one to all three ARBs).

- [ ] **Step 2: Update `app/README.md`**

Add to the Features list: "Content moderation — users can report reviews (spam/inappropriate/fake/other); admins can delete any review or place and resolve reports from a dedicated Moderation screen." Add "Moderation" to the Testing section's test-group table (new row: `| \`SampleReportsRepository\` | Report submit/fetchOpen/resolve | \`ReportSubmitter\`/\`ReportResolver\` | Report submission and resolution business logic | \`isAdminProvider\` | Admin-role check, empty when signed out |`).

- [ ] **Step 3: Commit**

```bash
git add app/README.md
git commit -m "Document Phase 1 moderation tools in app/README.md"
```

---

## Self-Review Notes

- Spec coverage: migration + RLS (Task 1), `Review.authorId` + delete methods (Task 2), `Report`/`ReportsRepository` (Task 3), admin detection (Task 4, deliberately reworked from the spec's `AppUser.isAdmin` sketch — documented in Global Constraints), report submit/resolve business logic (Task 5), report UI on `ReviewTile` (Task 6), admin place-deletion UI (Task 7 — added beyond the spec's literal text since the spec's Feature section claims this capability exists "directly from its existing screen," which required adding the affordance since none existed), Moderation screen + Profile entry point (Task 8), verification + docs (Task 9). ✅
- No placeholders. Task 7's first `_confirmDeletePlace` draft is intentionally shown as a wrong/discarded attempt and immediately corrected in the same step, matching how the real file should end up — not a genuine ambiguity, but flagged for the implementer to avoid confusion.
- Type consistency: `ReportReason`/`ReportStatus` enums, `Report` fields, and `ReportsRepository` method signatures match verbatim across Tasks 3, 5, 6, 8. `isAdminProvider` (`FutureProvider<bool>`) usage is consistent (`.valueOrNull ?? false` in Tasks 7/8, `.future` in Task 4's test).
