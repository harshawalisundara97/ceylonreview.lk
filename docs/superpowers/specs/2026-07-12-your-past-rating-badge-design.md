# "You've Been Here Before" Badge — Design

Date: 2026-07-12
Status: Approved by user

First phase of the broader "enhance this app" initiative (which was
decomposed into four independent sub-projects: this badge feature, a UI/UX
polish pass, trust & safety, and performance/reliability — each to get its
own spec/plan/build cycle).

## Problem

Users sometimes forget they've already reviewed a place — including places
they didn't enjoy — and end up considering it again without remembering
their own past experience. There's currently no way to see, at a glance
while browsing, "I've already been here and rated it."

## Feature

A private badge on `PlaceCard` — visible only to the signed-in user who
wrote the review, never to anyone else — showing their own past rating for
that place, e.g. a small pill reading "You: 4★". Shown for any place the
user has previously reviewed, regardless of whether the rating was good or
bad; the user decides what to do with that information.

## Data

No backend or schema changes. The app already fetches the signed-in user's
own reviews via `myReviewsProvider` (`app/lib/application/reviews_provider.dart`),
backed by `ReviewsRepository.fetchMine()` — used today by the Profile
screen. A new derived provider is built purely client-side from that data:

```dart
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

Signed-out users: `myReviewsProvider` already resolves to an empty list
when signed out, so the map is empty and no badges render — no extra
auth-gating logic needed in the UI.

## UI

`PlaceCard` (`app/lib/presentation/widgets/place_card.dart`) reads
`myReviewRatingsProvider` and, when the card's `place.id` has an entry,
renders a small rounded pill badge — "You: N★" — in a corner of the card
(placement to match the existing COMMUNITY badge's positioning
convention, not overlapping the favorite-heart icon). Uses existing
typography/color tokens (`AppTypography.overline`, `CeylonTokens.star`),
consistent with the rest of the card's existing badges.

This is the only file that needs UI changes — every screen that already
renders `PlaceCard` (Home carousels, Category grid, Profile) picks up the
badge automatically, since they all go through the same widget.

## Error handling

`myReviewsProvider` already handles its own loading/error states as an
`AsyncValue`; this feature only reads `.valueOrNull`, so a transient
load failure just means the badge doesn't show yet (never a card-level
error) — consistent with how favorite-heart state already behaves via
`myFavoriteIdsProvider`.

## Testing

- Widget test: `PlaceCard` shows the "You: N★" badge when
  `myReviewRatingsProvider` (overridden in the test) has an entry for the
  card's place id.
- Widget test: `PlaceCard` shows no badge when the map has no entry for
  that place id (including the signed-out case, where the map is empty).

## Out of scope

- Any change to how ratings/reviews are stored or computed.
- Any indicator visible to other users (this is explicitly private).
- The other three phases of "enhance this app" (UI polish, trust & safety,
  performance) — separate specs.
