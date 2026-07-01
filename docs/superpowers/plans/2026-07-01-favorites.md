# Favorites Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let signed-in users bookmark places from a `PlaceCard` or the place detail screen, and see them under a new "Your Favorites" section on Profile.

**Architecture:** New `favorites` Supabase table (RLS-scoped per user) behind a `FavoritesRepository` interface, with a Supabase implementation (production) and an in-memory sample implementation (tests/offline), following the exact same three-layer pattern already used for reviews (`ReviewsRepository` / `SupabaseReviewsRepository` / `SampleReviewsRepository`). A Riverpod `AsyncNotifier<Set<String>>` (`myFavoriteIdsProvider`) holds the current user's favorite place IDs with optimistic toggle; `PlaceCard`, the place detail screen, and the Profile screen all read from it.

**Tech Stack:** Flutter, Riverpod (`flutter_riverpod`), Supabase (Postgres + RLS via `supabase_flutter`), `flutter_test` for unit/widget tests.

## Global Constraints

- Favorites require sign-in; no anonymous favorites (spec: "Decisions locked in").
- Toggle must appear in exactly two places: `PlaceCard` (heart icon overlay) and the place detail screen — not a third location.
- Saved favorites render on the Profile screen as a new "Your Favorites" section, not a new bottom-nav tab.
- No new bottom-nav tab, no favorite collections/folders, no sort/filter on the favorites list (out of scope per spec).
- Match the existing repository-interface / Supabase-impl / sample-impl three-file pattern exactly (see `reviews_repository.dart` / `supabase_reviews_repository.dart` / `sample_reviews_repository.dart`).

---

### Task 1: Supabase schema — `favorites` table + RLS

**Files:** None (Supabase migration applied via MCP tools, not a repo file — this project's Supabase schema lives in the cloud project, tracked in `docs/BACKEND_PLAN.md` for reference, not as local `.sql` files).

**Interfaces:**
- Produces: a `public.favorites` table with columns `user_id uuid`, `place_id text`, `created_at timestamptz`, primary key `(user_id, place_id)`, referenced by Task 3's `SupabaseFavoritesRepository`.

- [ ] **Step 1: Apply the migration**

Use the Supabase MCP `apply_migration` tool with `project_id: jrepeqykdgsckrlvujnt`, `name: create_favorites_table`, and this SQL:

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

- [ ] **Step 2: Verify the table and RLS**

Use the Supabase MCP `execute_sql` tool with `project_id: jrepeqykdgsckrlvujnt`:
```sql
select tablename, rowsecurity from pg_tables where tablename = 'favorites';
select policyname, cmd from pg_policies where tablename = 'favorites';
```
Expected: one row with `rowsecurity = true`, and three policies (`select`, `insert`, `delete`).

- [ ] **Step 3: Check for new security warnings**

Use the Supabase MCP `get_advisors` tool with `project_id: jrepeqykdgsckrlvujnt`, `type: security`.
Expected: no new warnings referencing `favorites` (the pre-existing `auth_leaked_password_protection` warning is unrelated and stays).

No commit for this task — it's a cloud-only change with nothing to add to git.

---

### Task 2: `FavoritesRepository` interface + in-memory sample implementation

**Files:**
- Create: `app/lib/domain/repositories/favorites_repository.dart`
- Create: `app/lib/data/sample/sample_favorites_repository.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Produces: `abstract interface class FavoritesRepository` with `Future<Set<String>> fetchMyFavoriteIds()`, `Future<void> add(String placeId)`, `Future<void> remove(String placeId)`. Consumed by Task 3 (`SupabaseFavoritesRepository implements FavoritesRepository`) and Task 4 (`favoritesRepositoryProvider`).

- [ ] **Step 1: Write the failing test**

Add this group to `app/test/ceylon_review_test.dart` (add the import at the top alongside the other sample-repo imports, then add the group after the existing `SampleReviewsRepository` group):

```dart
import 'package:ceylon_review/data/sample/sample_favorites_repository.dart';
```

```dart
  group('SampleFavoritesRepository', () {
    test('starts empty, add/remove update the id set', () async {
      final repo = SampleFavoritesRepository();
      expect(await repo.fetchMyFavoriteIds(), isEmpty);

      await repo.add('odel');
      expect(await repo.fetchMyFavoriteIds(), {'odel'});

      await repo.add('mirissa-beach');
      expect(await repo.fetchMyFavoriteIds(), {'odel', 'mirissa-beach'});

      await repo.remove('odel');
      expect(await repo.fetchMyFavoriteIds(), {'mirissa-beach'});
    });

    test('removing a non-favorited id is a no-op', () async {
      final repo = SampleFavoritesRepository();
      await repo.remove('never-added');
      expect(await repo.fetchMyFavoriteIds(), isEmpty);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:ceylon_review/data/sample/sample_favorites_repository.dart'`

- [ ] **Step 3: Write the interface**

Create `app/lib/domain/repositories/favorites_repository.dart`:

```dart
/// Read/write access to the signed-in user's favorited places.
abstract interface class FavoritesRepository {
  /// The place ids the current user has favorited.
  Future<Set<String>> fetchMyFavoriteIds();

  Future<void> add(String placeId);

  Future<void> remove(String placeId);
}
```

- [ ] **Step 4: Write the in-memory implementation**

Create `app/lib/data/sample/sample_favorites_repository.dart`:

```dart
import '../../domain/repositories/favorites_repository.dart';

/// In-memory implementation: starts empty; favorites persist for the session.
class SampleFavoritesRepository implements FavoritesRepository {
  final Set<String> _favoriteIds = {};

  @override
  Future<Set<String>> fetchMyFavoriteIds() async => {..._favoriteIds};

  @override
  Future<void> add(String placeId) async => _favoriteIds.add(placeId);

  @override
  Future<void> remove(String placeId) async => _favoriteIds.remove(placeId);
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: PASS (all tests, including the two new ones)

- [ ] **Step 6: Commit**

```bash
git add app/lib/domain/repositories/favorites_repository.dart app/lib/data/sample/sample_favorites_repository.dart app/test/ceylon_review_test.dart
git commit -m "Add FavoritesRepository interface and in-memory implementation"
```

---

### Task 3: `SupabaseFavoritesRepository` + register in DI

**Files:**
- Create: `app/lib/data/supabase/supabase_favorites_repository.dart`
- Modify: `app/lib/application/repository_providers.dart`

**Interfaces:**
- Consumes: `FavoritesRepository` (Task 2), `SupabaseClient` from `supabase_flutter`.
- Produces: `SupabaseFavoritesRepository implements FavoritesRepository`, and `final favoritesRepositoryProvider = Provider<FavoritesRepository>(...)` in `repository_providers.dart`. Consumed by Task 4's `favorites_provider.dart`.

- [ ] **Step 1: Write the Supabase implementation**

Create `app/lib/data/supabase/supabase_favorites_repository.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/favorites_repository.dart';

/// Favorites backed by the Supabase `favorites` table (RLS-scoped to the
/// signed-in user).
class SupabaseFavoritesRepository implements FavoritesRepository {
  SupabaseFavoritesRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Set<String>> fetchMyFavoriteIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};
    final rows =
        await _client.from('favorites').select('place_id').eq('user_id', userId);
    return rows.map((row) => row['place_id'] as String).toSet();
  }

  @override
  Future<void> add(String placeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save favorites.');
    }
    await _client
        .from('favorites')
        .insert({'user_id': userId, 'place_id': placeId});
  }

  @override
  Future<void> remove(String placeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('place_id', placeId);
  }
}
```

- [ ] **Step 2: Register the provider**

In `app/lib/application/repository_providers.dart`, add the import and provider (this file has no existing test — it's pure DI wiring, matching the other two repositories already there):

```dart
import '../data/supabase/supabase_favorites_repository.dart';
import '../domain/repositories/favorites_repository.dart';
```

```dart
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
    (ref) => SupabaseFavoritesRepository(Supabase.instance.client));
```

- [ ] **Step 3: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add app/lib/data/supabase/supabase_favorites_repository.dart app/lib/application/repository_providers.dart
git commit -m "Add SupabaseFavoritesRepository and register in DI"
```

---

### Task 4: `myFavoriteIdsProvider` with optimistic toggle

**Files:**
- Create: `app/lib/application/favorites_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `favoritesRepositoryProvider` (Task 3), `authProvider` (`app/lib/application/auth_provider.dart`, `AppUser?` state).
- Produces: `final myFavoriteIdsProvider = AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(FavoriteIdsNotifier.new)` with a `toggle(String placeId)` method. Consumed by Task 5 (`PlaceCard`), Task 6 (place detail screen), Task 7 (Profile screen).

- [ ] **Step 1: Write the failing test**

Add this group to `app/test/ceylon_review_test.dart` (add these imports alongside the existing ones):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ceylon_review/application/auth_provider.dart';
import 'package:ceylon_review/application/favorites_provider.dart';
import 'package:ceylon_review/application/repository_providers.dart';
import 'package:ceylon_review/data/sample/sample_favorites_repository.dart';
import 'package:ceylon_review/domain/models/user.dart';
import 'package:ceylon_review/domain/repositories/favorites_repository.dart';
```

```dart
  group('myFavoriteIdsProvider', () {
    ProviderContainer buildContainer(FavoritesRepository repo, AppUser? user) {
      return ProviderContainer(overrides: [
        favoritesRepositoryProvider.overrideWithValue(repo),
        authProvider.overrideWith(() => _FakeAuthNotifier(user)),
      ]);
    }

    test('signed-out user has no favorites and toggle is a no-op', () async {
      final container = buildContainer(SampleFavoritesRepository(), null);
      addTearDown(container.dispose);

      final ids = await container.read(myFavoriteIdsProvider.future);
      expect(ids, isEmpty);
    });

    test('toggle adds then removes a place id, backed by the repository',
        () async {
      final repo = SampleFavoritesRepository();
      final container = buildContainer(
          repo, const AppUser(name: 'Test User', email: 't@example.com'));
      addTearDown(container.dispose);

      await container.read(myFavoriteIdsProvider.future);
      await container.read(myFavoriteIdsProvider.notifier).toggle('odel');
      expect(container.read(myFavoriteIdsProvider).value, {'odel'});
      expect(await repo.fetchMyFavoriteIds(), {'odel'});

      await container.read(myFavoriteIdsProvider.notifier).toggle('odel');
      expect(container.read(myFavoriteIdsProvider).value, isEmpty);
      expect(await repo.fetchMyFavoriteIds(), isEmpty);
    });
  });
```

Add this fake notifier near the bottom of the file (outside `main()`), since `AuthNotifier.build()` reads `authRepositoryProvider`, which the test doesn't want to wire up:

```dart
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AppUser? _user;

  @override
  AppUser? build() => _user;
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:ceylon_review/application/favorites_provider.dart'`

- [ ] **Step 3: Write the provider**

Create `app/lib/application/favorites_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'repository_providers.dart';

class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final user = ref.watch(authProvider);
    if (user == null) return const <String>{};
    return ref.watch(favoritesRepositoryProvider).fetchMyFavoriteIds();
  }

  /// Adds or removes [placeId], updating local state immediately and
  /// reverting if the backing repository call fails.
  Future<void> toggle(String placeId) async {
    final current = state.valueOrNull ?? const <String>{};
    final wasFavorite = current.contains(placeId);
    final optimistic = {...current};
    wasFavorite ? optimistic.remove(placeId) : optimistic.add(placeId);
    state = AsyncData(optimistic);

    final repo = ref.read(favoritesRepositoryProvider);
    try {
      if (wasFavorite) {
        await repo.remove(placeId);
      } else {
        await repo.add(placeId);
      }
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}

final myFavoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(
        FavoriteIdsNotifier.new);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: PASS (all tests)

- [ ] **Step 5: Commit**

```bash
git add app/lib/application/favorites_provider.dart app/test/ceylon_review_test.dart
git commit -m "Add myFavoriteIdsProvider with optimistic toggle"
```

---

### Task 5: Heart toggle on `PlaceCard`

**Files:**
- Modify: `app/lib/presentation/widgets/place_card.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `myFavoriteIdsProvider` (Task 4).
- Produces: `PlaceCard` becomes a `ConsumerWidget` (was `StatelessWidget`); its public constructor and fields (`place`, `onTap`, `width`, `distanceKm`) are unchanged, so Task 6/7 and the existing call sites in `home_screen.dart`/`category_screen.dart` need no changes.

- [ ] **Step 1: Write the failing test**

Add this group to `app/test/ceylon_review_test.dart`, inside the existing `group('Widgets', ...)` block (it already has a `themed()` helper and imports `flutter_riverpod`/`ProviderScope` is not yet imported — add `import 'package:flutter_riverpod/flutter_riverpod.dart';` if Task 4's test didn't already add it):

```dart
    testWidgets('PlaceCard heart toggles favorite state', (tester) async {
      final repo = SampleFavoritesRepository();
      final place = (await SamplePlacesRepository().fetchAll())
          .firstWhere((p) => p.id == 'odel');

      await tester.pumpWidget(ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(repo),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(name: 'Test User', email: 't@example.com'))),
        ],
        child: themed(PlaceCard(place: place, onTap: () {})),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(await repo.fetchMyFavoriteIds(), {'odel'});
    });
```

Note: `themed()` currently wraps its child in `MaterialApp(...)` directly — it needs to be wrapped in `ProviderScope` too for any widget that reads providers. Since `RatingStars`/`StarPicker` (the two existing widgets tested there) don't use Riverpod, `themed()` has never needed one. Update `themed()` in the test file to accept the override list and wrap accordingly:

```dart
    Widget themed(Widget child, {List<Override> overrides = const []}) =>
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.of(PlaceCategory.home, Brightness.light),
            home: Scaffold(body: Center(child: child)),
          ),
        );
```

...and pass overrides through `themed()` instead of wrapping separately:

```dart
      await tester.pumpWidget(themed(
        PlaceCard(place: place, onTap: () {}),
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(repo),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(name: 'Test User', email: 't@example.com'))),
        ],
      ));
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: FAIL — `favorite_border_rounded` icon not found (PlaceCard doesn't render a heart yet)

- [ ] **Step 3: Add the heart toggle to `PlaceCard`**

In `app/lib/presentation/widgets/place_card.dart`, change the class declaration and imports:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/favorites_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/place.dart';

/// Place card: full-bleed photo with bottom scrim, name, category overline,
/// rating and review count. Two layouts: carousel (fixed width) and list.
class PlaceCard extends ConsumerWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.width,
    this.distanceKm,
  });

  final Place place;
  final VoidCallback onTap;
  final double? width;
  final double? distanceKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<CeylonTokens>()!;
    final seed = AppColors.seedOf(place.category);
    final isFavorite =
        (ref.watch(myFavoriteIdsProvider).valueOrNull ?? const {})
            .contains(place.id);
```

(This replaces the old `class PlaceCard extends StatelessWidget` header, its constructor/fields, and the start of `Widget build(BuildContext context) {`.)

Then add the heart button as a `Positioned` sibling inside the existing photo `Stack` (alongside the category-label `Positioned` widget), right after that `Positioned` block and before the closing `],` of the `Stack`'s `children`:

```dart
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () => ref
                            .read(myFavoriteIdsProvider.notifier)
                            .toggle(place.id),
                      ),
                    ),
                  ),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/ceylon_review_test.dart`
Expected: PASS (all tests)

- [ ] **Step 5: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add app/lib/presentation/widgets/place_card.dart app/test/ceylon_review_test.dart
git commit -m "Add heart favorite toggle to PlaceCard"
```

---

### Task 6: Heart toggle on the place detail screen

**Files:**
- Modify: `app/lib/presentation/screens/place_detail/place_detail_screen.dart`

**Interfaces:**
- Consumes: `myFavoriteIdsProvider` (Task 4). `_PlaceDetailBody` is already a `ConsumerWidget`, so no class-type change is needed here (unlike Task 5).

This screen has no existing widget test coverage (matching `home_screen.dart`/`category_screen.dart`, neither of which gained tests in the Phase 1 search/discovery work) — verify manually per Task 8 instead of adding a new test harness for a single icon.

- [ ] **Step 1: Add the heart toggle next to the district/rating row**

In `app/lib/presentation/screens/place_detail/place_detail_screen.dart`, inside `_PlaceDetailBody.build`, add this line after `final reviews = ref.watch(reviewsForPlaceProvider(place.id));`:

```dart
    final isFavorite =
        (ref.watch(myFavoriteIdsProvider).valueOrNull ?? const {})
            .contains(place.id);
```

Then change the `Row` that currently ends with the district `Text` (the one right after `Text(place.description, ...)`'s preceding block — specifically the `Row` containing `place.ratingLabel`, `RatingStars`, and the district) to add a heart button after the district `Text`:

```dart
                  Row(
                    children: [
                      Text(place.ratingLabel,
                          style: theme.textTheme.displayMedium),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingStars(rating: place.rating),
                          Text('${place.reviewCountLabel} reviews',
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.place_rounded,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 2),
                      Text(place.district,
                          style: theme.textTheme.titleSmall),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? Colors.redAccent
                              : theme.colorScheme.outline,
                        ),
                        onPressed: () => ref
                            .read(myFavoriteIdsProvider.notifier)
                            .toggle(place.id),
                      ),
                    ],
                  ),
```

- [ ] **Step 2: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add app/lib/presentation/screens/place_detail/place_detail_screen.dart
git commit -m "Add favorite toggle to place detail screen"
```

---

### Task 7: "Your Favorites" section on Profile

**Files:**
- Modify: `app/lib/presentation/screens/profile/profile_screen.dart`

**Interfaces:**
- Consumes: `myFavoriteIdsProvider` (Task 4), `allPlacesProvider` (already watched on this screen), `PlaceCard` (Task 5).

No new test harness for the same reason as Task 6 — verify manually per Task 8.

- [ ] **Step 1: Add imports**

In `app/lib/presentation/screens/profile/profile_screen.dart`, add:

```dart
import '../../../application/favorites_provider.dart';
import '../../widgets/place_card.dart';
import '../place_detail/place_detail_screen.dart';
```

- [ ] **Step 2: Read the favorites**

In `ProfileScreen.build`, add alongside the other `ref.watch` calls:

```dart
    final favoriteIds = ref.watch(myFavoriteIdsProvider);
```

- [ ] **Step 3: Add the "Your Favorites" section**

Insert this new section into the `ListView`'s `children`, directly after the closing `const Divider(height: 1),` that follows the Dark Mode `SwitchListTile` and before the existing "Your Reviews" header `Padding`:

```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                  AppSpacing.xl, AppSpacing.gutter, AppSpacing.sm),
              child:
                  Text('Your Favorites', style: theme.textTheme.titleLarge),
            ),
            favoriteIds.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(AppSpacing.gutter),
                child: Text('Could not load your favorites.'),
              ),
              data: (ids) {
                final places = (placesAsync.valueOrNull ?? [])
                    .where((p) => ids.contains(p.id))
                    .toList();
                if (places.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.gutter),
                    child: Text(
                      'No favorites yet. Tap the heart on a place you love!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final place in places)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                            0, AppSpacing.gutter, AppSpacing.md),
                        child: PlaceCard(
                          place: place,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailScreen(placeId: place.id),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const Divider(height: 1),
```

- [ ] **Step 4: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add app/lib/presentation/screens/profile/profile_screen.dart
git commit -m "Add Your Favorites section to Profile screen"
```

---

### Task 8: End-to-end verification and README update

**Files:**
- Modify: `README.md`
- Modify: `app/README.md`

**Interfaces:** None — this task verifies the whole feature and documents it, consuming nothing new.

- [ ] **Step 1: Run the full test suite**

Run: `cd app && flutter test`
Expected: All tests pass, including every group added in Tasks 2, 4, and 5.

- [ ] **Step 2: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Manual on-device verification**

Run: `cd app && flutter run` (pick a connected device/emulator).
Manually check:
- Sign in, tap the heart on a `PlaceCard` on Home — it fills red immediately.
- Open that place's detail screen — the heart there shows filled too.
- Un-favorite from the detail screen — go back to Home, the card's heart is back to outline.
- Favorite 2–3 places, open Profile — they all appear under "Your Favorites" using the same card layout as everywhere else.
- Tap a card under "Your Favorites" — it opens that place's detail screen.
- Sign out and back in — favorites are still there (confirms they're read from Supabase, not just local state).

- [ ] **Step 4: Cross-check via Supabase MCP**

Use the Supabase MCP `execute_sql` tool with `project_id: jrepeqykdgsckrlvujnt`:
```sql
select * from public.favorites order by created_at desc;
```
Expected: rows matching what you favorited in Step 3, each with your test user's `user_id`.

- [ ] **Step 5: Update READMEs**

In `app/README.md`, add a bullet under `## Features` (after the search & discovery bullet added in the previous phase):

```markdown
- **Favorites** — bookmark places from any card or the detail screen; saved places appear under "Your Favorites" on your profile
```

In `README.md` (root), add the matching bullet under `### Features` in the same place:

```markdown
- Favorites: bookmark any place from its card or detail page, view them all under "Your Favorites" on your profile
```

- [ ] **Step 6: Commit**

```bash
git add README.md app/README.md
git commit -m "Document Favorites feature in READMEs"
```
