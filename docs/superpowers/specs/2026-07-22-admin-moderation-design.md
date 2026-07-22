# Admin & Moderation Tools — Design

Date: 2026-07-22
Status: Approved by user

Phase 1 of the backend/frontend enhancement roadmap (`~/.claude/plans/effervescent-mixing-avalanche.md`) — content moderation only. User banning/suspension is explicitly deferred to a later phase (requires a Supabase Edge Function with service-role access to the Auth Admin API; out of scope here).

## Problem

There is currently no way to remove a bad review or an inappropriate
community-added place except direct SQL against the database. There is also
no way for a regular user to flag content they believe is spam, fake, or
otherwise inappropriate — the only recourse today is contacting the app
owner outside the app entirely.

## Feature

- Any signed-in user can report a review (not their own) with a reason and
  an optional note.
- An `admin`-role user gets a "Moderation" screen (reachable from Profile,
  admin-only) listing open reports, and can delete the reported review or
  dismiss the report.
- Admins can also delete any review or place directly from its existing
  screen (place detail / review list) — the same admin-bypass RLS that
  powers the moderation screen's delete action also applies wherever a
  delete affordance already exists or gets added, so "un-publishing a bad
  place" is just an admin deleting it, no separate UI.
- Admin role is assigned manually via SQL for now; there is no in-app
  promote-to-admin UI in this phase.

## Data model & backend

New Supabase migration:

```sql
-- profiles gains a role column
alter table public.profiles
  add column role text not null default 'user'
    check (role in ('user', 'admin'));

-- helper used by all three new RLS policies below
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

-- Admin bypass for content removal, alongside existing owner-only policies
create policy "Admins can delete any review"
  on public.reviews for delete
  using (public.is_admin());

create policy "Admins can delete any place"
  on public.places for delete
  using (public.is_admin());
```

`is_admin()` is `security definer` specifically so RLS policies on
`reports`/`reviews`/`places` can check the caller's role without those
policies themselves needing read access to `profiles` (avoids a recursive
RLS dependency).

Regular users cannot read `role` off other profiles — the existing
`profiles` RLS ("readable by all") already permits reading your own row
including `role`; the app only needs to read its own `role` to decide
whether to show the Moderation entry point, so no policy change is needed
there.

## Domain & data layer

- `app/lib/domain/models/user.dart` (`AppUser`): add `final bool isAdmin`.
- `app/lib/data/supabase/supabase_auth_repository.dart`: `_toAppUser` reads
  `role` from the `profiles` row (requires fetching the profile row
  alongside the auth user — the repository already has `currentUser`
  reading from `_client.auth.currentUser`; add a profile fetch by id to
  populate `isAdmin`, done once at sign-in/session-restore, mirroring how
  `name` is already sourced from user metadata today).
- `app/lib/data/sample/sample_auth_repository.dart`: `isAdmin: false` for
  all sample users (no admin testing via the offline sample repo — admin
  behavior is tested via a fake/override in tests, same pattern as
  `_FakeAuthNotifier`).
- New `app/lib/domain/models/report.dart`: `Report` (id, reviewId,
  reporterId, reason, note, status, createdAt) plus a `ReportReason` enum
  (spam, inappropriate, fake, other) with a `label` getter for display.
- New `app/lib/domain/repositories/reports_repository.dart`:
  `abstract interface class ReportsRepository { Future<void> submit(...); Future<List<Report>> fetchOpen(); Future<void> resolve(String reportId, {required bool actioned}); }`
- New `app/lib/data/supabase/supabase_reports_repository.dart` and
  `app/lib/data/sample/sample_reports_repository.dart`, wired through
  `app/lib/application/repository_providers.dart` exactly like every other
  repository pair in this codebase.
- `app/lib/domain/repositories/reviews_repository.dart` /
  `SupabaseReviewsRepository` / `SampleReviewsRepository`: add
  `Future<void> delete(String reviewId)`.
- `app/lib/domain/repositories/places_repository.dart` /
  `SupabasePlacesRepository` / `SamplePlacesRepository`: add
  `Future<void> delete(String placeId)`.

## Providers

- `app/lib/application/reports_provider.dart` (new): `openReportsProvider`
  (`FutureProvider<List<Report>>`), a `ReportSubmitter` class (mirrors
  `ReviewSubmitter`'s shape) with `submit({required reviewId, required
  reason, String? note})`, and a `ReportResolver` with
  `resolve(reportId, {required actioned})` that also deletes the
  underlying review when `actioned` is true, then invalidates
  `openReportsProvider` plus the same review-list providers
  `ReviewSubmitter` already invalidates.

## UI

- `ReviewTile`: a small flag/report `IconButton` next to the existing
  star rating, hidden when the review's author is the current user.
  `Review` has no author-id field today (only the denormalized
  `authorName`), so add `final String authorId` to `Review` and thread
  it through `_reviewFromRow`/`add()` the same way `photoUrls` was added;
  the tile compares `review.authorId` against the signed-in user's id to
  decide whether to show the button. Tapping opens a modal bottom sheet:
  reason `ChoiceChip` row (Spam / Inappropriate / Fake / Other) + optional
  note `TextField` + Submit button.
- Profile screen: a "Moderation" `ListTile` (icon: `Icons.shield_rounded`),
  inserted only `if (user.isAdmin)`, opening `ModerationScreen`.
- New `app/lib/presentation/screens/moderation/moderation_screen.dart`:
  a list of open reports, each row showing the review's author/text
  snippet/rating (reusing `ReviewTile` in a read-only context or a
  lighter-weight row — reuse `ReviewTile` directly, it has no built-in
  edit affordance) plus the report's reason/note, with two actions:
  "Delete review" (calls `ReportResolver.resolve(id, actioned: true)`)
  and "Dismiss" (`actioned: false`). Empty state: "No open reports."

## Error handling

- Report submission and moderation actions reuse the existing
  `AuthFailure`-style catch/snackbar pattern already used throughout
  (login, write-review, add-place).
- `openReportsProvider`'s `AsyncValue` error state renders the same
  "Could not load..." pattern already used by every other list screen
  (leaderboard, reviews, favorites).

## Testing

- `ReportsRepository` (sample): submit, fetchOpen returns only `status =
  'open'`, resolve updates status and (when `actioned`) also removes the
  review from `SampleReviewsRepository`.
- Widget: `ReviewTile` shows the report button for others' reviews, hides
  it for the current user's own review; tapping it and submitting opens
  and closes the sheet and calls `submit` with the chosen reason.
- Widget: Profile screen shows the Moderation row only when
  `isAdmin: true` (override via `_FakeAuthNotifier`-style fake carrying
  an admin `AppUser`).
- Widget: `ModerationScreen` lists open reports, "Delete review" removes
  it from the list and (verified via the fake repository) also removes
  the underlying review; "Dismiss" removes it from the list without
  touching the review.

## Out of scope

- Banning/suspending user accounts (needs a service-role Edge Function —
  later phase).
- Reporting places (only reviews, per this phase's scope).
- Any in-app admin-promotion UI (role assignment stays manual SQL).
- Notifications to the reporter when their report is actioned (Phase 2 of
  the roadmap covers notifications generally; not duplicated here).
