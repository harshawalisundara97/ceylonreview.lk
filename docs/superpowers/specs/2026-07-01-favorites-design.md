# Favorites (Phase 2a of App Modernization)

## Context

Following the Search & Discovery upgrade (Phase 1), the next enhancement is
favorites/bookmarking — letting signed-in users save places they love and
find them again from their Profile. This is deliberately scoped smaller than
the original "Favorites + Photo uploads" idea: photo uploads need Supabase
Storage, an image picker, and upload UI, which is a separate, larger effort
(Phase 2b). Favorites is a small, self-contained, high-payoff feature that
reuses existing patterns in the app (the "Your Reviews" section on Profile,
the repository/provider swap-point architecture from the Supabase backend
work).

Decisions locked in during design:
- Favorite toggle appears in two places: a heart icon on every `PlaceCard`
  (home, category, search results) and a prominent toggle on the place detail
  screen.
- Saved favorites are shown in a new "Your Favorites" section on the Profile
  screen, directly mirroring the existing "Your Reviews" section — not a new
  bottom nav tab.
- Favorites are per-user and require sign-in (consistent with reviews).

## Data model & backend

New Supabase migration:
```sql
create table public.favorites (
  user_id uuid not null references public.profiles on delete cascade,
  place_id text not null references public.places on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, place_id)
);
create index on public.favorites (place_id);

alter table public.favorites enable row level security;

create policy "Users can view their own favorites"
  on public.favorites for select
  using (auth.uid() = user_id);

create policy "Users can add their own favorites"
  on public.favorites for insert
  with check (auth.uid() = user_id);

create policy "Users can remove their own favorites"
  on public.favorites for delete
  using (auth.uid() = user_id);
```
No trigger needed — favorites don't affect `places.rating`/`review_count`.
Run `get_advisors` after migrating to confirm RLS is correctly scoped.

## Domain & data layer

- New `app/lib/domain/repositories/favorites_repository.dart`:
  ```dart
  abstract interface class FavoritesRepository {
    Future<Set<String>> fetchMyFavoriteIds();
    Future<void> add(String placeId);
    Future<void> remove(String placeId);
  }
  ```
- New `app/lib/data/supabase/supabase_favorites_repository.dart` implementing
  it against the `favorites` table, scoped to `auth.currentUser!.id` (same
  pattern as `supabase_reviews_repository.dart`'s `add` using `auth.uid()`).
- Register in `app/lib/application/repository_providers.dart` alongside the
  existing three repository providers.

## State management

- New `app/lib/application/favorites_provider.dart`:
  - `myFavoriteIdsProvider`: `FutureProvider<Set<String>>` wrapping
    `fetchMyFavoriteIds()` (mirrors `myReviewsProvider` in
    `reviews_provider.dart`).
  - `FavoritesNotifier` (`AsyncNotifier<Set<String>>` or a simple toggle
    method on top of the above) exposing `toggle(String placeId)`: optimistic
    local update to the set, then calls `add`/`remove` on the repository,
    invalidating `myFavoriteIdsProvider` on completion or reverting on error.
- `PlaceCard` and the place detail screen read `myFavoriteIdsProvider` to
  determine heart-filled/outline state and call `toggle` on tap. If the user
  isn't signed in, tapping the heart is a no-op that's unreachable in
  practice (favorites UI only renders once signed in, matching how reviews
  already work).

## UI changes

- `app/lib/presentation/widgets/place_card.dart`: add a heart `IconButton`
  overlay (top-right corner of the photo, similar treatment to the existing
  category label overlay) that calls `toggle`. Filled heart = favorited,
  outline = not.
- `app/lib/presentation/screens/place_detail/place_detail_screen.dart`: add a
  heart toggle near the place name/rating (e.g. in the `SliverAppBar` actions
  or next to the title), same filled/outline treatment.
- `app/lib/presentation/screens/profile/profile_screen.dart`: add a "Your
  Favorites" section, structured like the existing "Your Reviews" section —
  cross-reference `myFavoriteIdsProvider` against `allPlacesProvider` (already
  watched on this screen) to render `PlaceCard`s for favorited places, with
  the same empty-state pattern ("No favorites yet...").

## Critical files

- `docs/BACKEND_PLAN.md` — reference for existing schema/RLS conventions
- `app/lib/domain/repositories/favorites_repository.dart` — new interface
- `app/lib/data/supabase/supabase_favorites_repository.dart` — new implementation
- `app/lib/application/repository_providers.dart` — register new repository
- `app/lib/application/favorites_provider.dart` — new providers
- `app/lib/presentation/widgets/place_card.dart` — heart toggle
- `app/lib/presentation/screens/place_detail/place_detail_screen.dart` — heart toggle
- `app/lib/presentation/screens/profile/profile_screen.dart` — Your Favorites section

## Out of scope (later)

- Photo uploads on reviews (Phase 2b — needs Supabase Storage + image picker)
- Review credibility features (helpful voting, verified visits) — Phase 3
- UI/UX modernization pass (skeleton loaders, animations) — Phase 4
- Sorting/filtering the favorites list, favorite collections/folders

## Verification

- `flutter analyze` clean; app builds and runs on device
- MCP `get_advisors` shows no new RLS/security warnings after the migration
- On device: sign in, favorite a place from a card and from its detail page,
  confirm the heart state stays in sync across both; open Profile and confirm
  it appears under "Your Favorites"; un-favorite and confirm it disappears;
  sign out/in and confirm favorites persist
- Cross-check `favorites` rows via MCP `execute_sql`
