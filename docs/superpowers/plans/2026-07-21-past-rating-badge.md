# "You've Been Here Before" Rating Badge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show a private "You: N★" pill badge on `PlaceCard` for any place the signed-in user has previously reviewed.

**Architecture:** A single derived, synchronous Riverpod `Provider<Map<String, int>>` (`myReviewRatingsProvider`) built from the existing `myReviewsProvider` FutureProvider's `.valueOrNull`; `PlaceCard` reads it and conditionally renders a badge. No backend changes, no new repository methods — purely client-side derivation and UI.

**Tech Stack:** Flutter, flutter_riverpod, existing `AppTypography`/`CeylonTokens` theme extension, existing gen-l10n localization (`youRated` ARB key already exists in all 3 locales).

Spec: `docs/superpowers/specs/2026-07-12-your-past-rating-badge-design.md`

## Global Constraints

- No backend/schema changes — this is a client-only derivation of already-fetched data.
- Badge is private: only ever shown to the signed-in author of the review, never to other users viewing the same place.
- No new auth-gating logic in the UI — `myReviewsProvider` already resolves to `[]` when signed out (`app/lib/application/reviews_provider.dart:18-21`), so the derived map is empty and no badge renders.
- Badge text uses the existing localized key `context.l10n.youRated(rating)` → `"You: {rating}★"` (already defined in `app/lib/l10n/app_en.arb`, `app_si.arb`, `app_ta.arb` — do not add a new key).
- Use `AppTypography.overline` and `CeylonTokens.star` for styling, consistent with the card's existing COMMUNITY badge and star icon.
- `flutter analyze` clean, `flutter test` all green (45 existing + new) before every commit.

---

### Task 1: `myReviewRatingsProvider`

**Files:**
- Modify: `app/lib/application/reviews_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `myReviewsProvider` (`FutureProvider<List<Review>>`, already defined at `reviews_provider.dart:18`), `Review.placeId` (`String`) and `Review.rating` (`int`, from `app/lib/domain/models/review.dart`).
- Produces: `myReviewRatingsProvider` — `Provider<Map<String, int>>`. Task 2 reads this via `ref.watch(myReviewRatingsProvider)`.

- [ ] **Step 1: Write the failing test**

Add to the `group('myFavoriteIdsProvider', ...)` sibling area in `app/test/ceylon_review_test.dart` a new group (place it near the other provider-only tests, e.g. after the `myFavoriteIdsProvider` group):

```dart
group('myReviewRatingsProvider', () {
  test('maps each place to the most recent rating, newest review wins',
      () async {
    final now = DateTime.now();
    final repo = SampleReviewsRepository();
    // Oldest first into the repo; fetchMine() must still return newest-first
    // for this test to be meaningful, matching production ordering.
    await repo.add(
      placeId: 'odel',
      authorName: 'Test User',
      rating: 2,
      text: 'First visit, not great.',
    );
    await repo.add(
      placeId: 'odel',
      authorName: 'Test User',
      rating: 5,
      text: 'Came back, loved it this time!',
    );

    final container = ProviderContainer(overrides: [
      reviewsRepositoryProvider.overrideWithValue(repo),
      authProvider.overrideWith(() => _FakeAuthNotifier(const AppUser(
          id: 'user-1', name: 'Test User', email: 't@example.com'))),
    ]);
    addTearDown(container.dispose);

    // Prime myReviewsProvider by awaiting it directly.
    await container.read(myReviewsProvider.future);

    final map = container.read(myReviewRatingsProvider);
    expect(map['odel'], 5);
  });

  test('empty when signed out', () {
    final container = ProviderContainer(overrides: [
      reviewsRepositoryProvider
          .overrideWithValue(SampleReviewsRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
    ]);
    addTearDown(container.dispose);

    expect(container.read(myReviewRatingsProvider), isEmpty);
  });
});
```

Check `SampleReviewsRepository.fetchMine()` (`app/lib/data/sample/sample_reviews_repository.dart`) returns newest-first — if it doesn't already, this test will fail for the right reason and you'll need to confirm the ordering matches production (`SupabaseReviewsRepository.fetchMine()` should already order by `created_at desc`; if the sample repo doesn't mirror that, note it in your report rather than changing repository behavior — this task only adds the derived provider).

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name myReviewRatingsProvider`
Expected: FAIL — `myReviewRatingsProvider` undefined.

- [ ] **Step 3: Add the provider**

In `app/lib/application/reviews_provider.dart`, add directly below `myReviewsProvider`:

```dart
/// Places the signed-in user has reviewed, mapped to their most recent
/// rating for that place. Empty when signed out.
final myReviewRatingsProvider = Provider<Map<String, int>>((ref) {
  final reviews = ref.watch(myReviewsProvider).valueOrNull ?? const [];
  final map = <String, int>{};
  for (final r in reviews) {
    // Reviews are fetched newest-first, so the first occurrence per
    // place is the most recent rating.
    map.putIfAbsent(r.placeId, () => r.rating);
  }
  return map;
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test --plain-name myReviewRatingsProvider`
Expected: PASS (both cases).

- [ ] **Step 5: Commit**

```bash
git add app/lib/application/reviews_provider.dart app/test/ceylon_review_test.dart
git commit -m "Add myReviewRatingsProvider derived from myReviewsProvider"
```

---

### Task 2: Badge on `PlaceCard`

**Files:**
- Modify: `app/lib/presentation/widgets/place_card.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `myReviewRatingsProvider` (`Provider<Map<String, int>>`, from Task 1); `context.l10n.youRated(String rating)` (existing, returns `"You: {rating}★"`); `AppTypography.overline(Color)`; `CeylonTokens.star` (existing `theme.extension<CeylonTokens>()!.star`, already used elsewhere in this file for the star icon color).
- Produces: nothing new — this is the final UI task for the feature.

- [ ] **Step 1: Write the failing test**

Add to the `group('Widgets', ...)` block in `app/test/ceylon_review_test.dart`, near the existing `'PlaceCard heart toggles favorite state'` test:

```dart
testWidgets('PlaceCard shows a past-rating badge when the user has '
    'reviewed this place', (tester) async {
  final place = (await SamplePlacesRepository().fetchAll())
      .firstWhere((p) => p.id == 'odel');

  await tester.pumpWidget(themed(
    PlaceCard(place: place, onTap: () {}),
    overrides: [
      favoritesRepositoryProvider
          .overrideWithValue(SampleFavoritesRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
      myReviewRatingsProvider.overrideWithValue({'odel': 4}),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.text('You: 4★'), findsOneWidget);
});

testWidgets(
    'PlaceCard shows no past-rating badge when the user has not '
    'reviewed this place', (tester) async {
  final place = (await SamplePlacesRepository().fetchAll())
      .firstWhere((p) => p.id == 'odel');

  await tester.pumpWidget(themed(
    PlaceCard(place: place, onTap: () {}),
    overrides: [
      favoritesRepositoryProvider
          .overrideWithValue(SampleFavoritesRepository()),
      authProvider.overrideWith(() => _FakeAuthNotifier(null)),
      myReviewRatingsProvider.overrideWithValue(const {}),
    ],
  ));
  await tester.pumpAndSettle();

  expect(find.textContaining('You:'), findsNothing);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "past-rating badge"`
Expected: FAIL — `myReviewRatingsProvider` used in override compiles fine (from Task 1), but `find.text('You: 4★')` finds nothing yet.

- [ ] **Step 3: Add the badge to `PlaceCard`**

In `app/lib/presentation/widgets/place_card.dart`, add the import and a watch call, then render the badge. The COMMUNITY badge lives bottom-left (`Positioned(left: AppSpacing.md, bottom: AppSpacing.sm, ...)`); the favorite heart is top-right. Place the new badge top-left so it can't collide with either.

Add near the top with the other imports:
```dart
import '../../application/reviews_provider.dart';
```

Inside `build`, alongside the existing `isFavorite` lookup:
```dart
    final myRating = ref.watch(myReviewRatingsProvider)[place.id];
```

Inside the image `Stack`'s `children`, add a new `Positioned` widget (alongside the existing bottom-left category/community row and the top-right favorite button):
```dart
                  if (myRating != null)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                size: 12, color: tokens.star),
                            const SizedBox(width: 4),
                            Text(
                              l10n.youRated('$myRating'),
                              style: AppTypography.overline(Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "past-rating badge"`
Expected: PASS (both cases).

- [ ] **Step 5: Run the full suite**

Run: `cd app && flutter analyze && flutter test`
Expected: `flutter analyze` clean (same 2 pre-existing info-level notices as before this branch, no new ones); `flutter test` all green (45 existing + 3 new = 48).

- [ ] **Step 6: Commit**

```bash
git add app/lib/presentation/widgets/place_card.dart app/test/ceylon_review_test.dart
git commit -m "Show a private past-rating badge on PlaceCard"
```

---

## Self-Review Notes

- Spec coverage: derived provider (Task 1), UI badge on `PlaceCard` only (Task 2), signed-out/no-review empty-map handling (Task 1's second test + Task 2's second test), private-only visibility (badge only ever reads the current user's own `myReviewRatingsProvider`, no place-level/other-user data involved), existing `youRated`/`AppTypography`/`CeylonTokens.star` reuse (Task 2). ✅
- No placeholders; every step has literal code.
- Type consistency: `myReviewRatingsProvider` is `Provider<Map<String, int>>` in both Task 1's definition and Task 2's `ref.watch(...)[place.id]` usage (`int?`) and test overrides (`Map<String, int>` literals). ✅
