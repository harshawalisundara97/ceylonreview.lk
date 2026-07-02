# Add a Place (Phase 3a) — Design

**Date:** 2026-07-02
**Status:** Approved by Harsha (in-session)
**Depends on:** Phase 1 (search/discovery, `locationProvider`) and Phase 2a (favorites) — branch `2026-07-01-search-discovery-upgrade` / PR #2.

## Goal

Users can review and rate places that don't exist in the app yet. When a place
is missing, a signed-in user adds it — full details plus a location picked on a
map (pin or current location) and a photo taken with the camera or chosen from
the gallery — and the place immediately becomes public for everyone to browse,
favorite, and review.

Phase 3b (photos attached to reviews) is a separate follow-up design that
reuses the photo-storage infrastructure built here.

## Decisions (locked in during brainstorming)

- **Visibility:** new places are public immediately, badged as community-added.
  No approval/moderation workflow (none exists in the app; can be added later).
- **Form scope:** the full place shape — name, category, district, description,
  price level, opening hours, photo — matching what seeded places have.
- **Entry points:** (1) search empty state, (2) a + button on the Map tab.
- **Location:** interactive map pin (tap/drag) + "use my current location"
  button. No address-search/geocoding in this phase.
- **Photos:** Supabase Storage; 1 photo per place (and, in Phase 3b, up to 3
  per review). Camera or gallery via `image_picker`, compressed client-side.
- **Storage model:** same `places` table with a nullable `added_by` column —
  not a separate table. Everything downstream (browse, search, filters,
  favorites, reviews, rating trigger, map pins) works on community places with
  zero changes.

## Data model & backend

Migration on `public.places`:

```sql
alter table public.places
  add column added_by uuid references public.profiles(id);
```

- `added_by` is null for the 18 seeded places; set to `auth.uid()` for
  community-added places.
- New RLS policies on `places`:
  - insert: authenticated users, `with_check (added_by = auth.uid())`
  - update/delete: `using (added_by = auth.uid())` — creators manage only
    their own places; seeded rows (null `added_by`) match no one.
  - select stays public (existing policy).
- Place `id` remains `text`. Seeded places use slugs; community places use a
  UUID string generated client-side (`const Uuid().v4()` via the `uuid`
  package, already a transitive dependency — add explicitly if not).

New **Supabase Storage bucket** `place-photos`:

- Public read.
- Authenticated users may upload only into a folder named after their user id
  (`place-photos/<uid>/<uuid>.jpg`), enforced by a storage policy on
  `storage.objects` checking `(storage.foldername(name))[1] = auth.uid()::text`.
- Creators may delete their own objects (same folder check).
- Uploaded images are compressed client-side (`flutter_image_compress`,
  max dimension 1600px, JPEG quality ~80) before upload.

Run `get_advisors` after the migration and bucket policies; no new warnings
expected.

## Domain & data layer

- `Place` model: add `addedBy` (`String?`). Map `added_by` in
  `SupabasePlacesRepository._placeFromRow`.
- `PlacesRepository` interface: add

  ```dart
  Future<Place> addPlace(Place place);
  ```

  `SupabasePlacesRepository` inserts the row (including `added_by` from the
  current session user; throws `StateError` if signed out — same convention as
  `SupabaseFavoritesRepository.add`). `SamplePlacesRepository` appends to its
  in-memory list.
- New `PhotoStorageRepository` (three-file pattern, reused by Phase 3b):

  ```dart
  abstract interface class PhotoStorageRepository {
    /// Uploads [bytes] and returns the public URL.
    Future<String> uploadPhoto(Uint8List bytes, {required String fileName});
    Future<void> deletePhoto(String url);
  }
  ```

  - `SupabasePhotoStorageRepository`: uploads to `place-photos/<uid>/...`,
    returns the public URL.
  - `SamplePhotoStorageRepository`: records uploads in memory, returns a fake
    URL.
- `repository_providers.dart`: add `photoStorageRepositoryProvider`.

## Application layer

- `AddPlaceController extends AsyncNotifier<void>` (pattern of existing
  submitters): a `submit(...)` method that (1) compresses + uploads the photo
  if one was picked, (2) calls `placesRepository.addPlace`, (3) invalidates
  `allPlacesProvider` / `placesByCategoryProvider` family /
  `filteredPlacesProvider` family so the new place appears everywhere
  immediately, (4) returns the created `Place` for navigation.
- Photo compression lives in a small helper (`compressImage(Uint8List) →
  Uint8List`) so the controller stays testable with the sample repos.

## Presentation

New `AddPlaceScreen` (`app/lib/presentation/screens/add_place/`):

- Signed-in users only; entry points are gated the same way reviews are.
- Fields: name (required), category (required, chip picker using the existing
  category theming), district (required), description (multiline, optional),
  price level (1–3 chips, shown only for food/hotels/shopping — reuses
  `categoryHasPricing()`), opening hours (optional open/close `TimeOfDay`
  pickers stored as "HH:mm"), photo (button opening a camera/gallery chooser
  via `image_picker`; thumbnail preview; optional but encouraged), location
  (required — see below).
- **Location picker:** an inline `flutter_map` (already a dependency) centered
  on Sri Lanka; tapping places/moves a pin; a "Use my current location" button
  reads the existing `locationProvider` (and triggers its permission flow).
  Validation requires a pin before save.
- On save: show progress on the submit button; on success navigate (replace)
  to `PlaceDetailScreen` for the new place — the existing "Write a Review"
  button is the natural next step for the user's first rating. On failure show
  a SnackBar and keep the form state.

Entry points:

- **Search empty state** (home screen search results): "Can't find it? Add
  this place" button, prefilling the name field with the search query.
- **Map tab:** a FloatingActionButton (+). If the user is signed out, tapping
  routes to sign-in messaging consistent with existing behavior.

Community badge: `PlaceCard` and the place detail screen show a small
"Community" chip when `place.addedBy != null`.

Android/iOS platform config: camera + photo library permission strings
(`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` in Info.plist;
Android needs no manifest change for `image_picker`'s default flow on API 33+,
add `CAMERA` permission only if `image_picker` requires it for capture).

## New dependencies

- `image_picker` (camera + gallery)
- `flutter_image_compress` (client-side compression)
- `uuid` (explicit, for place ids)

## Testing

- Unit: `SamplePlacesRepository.addPlace` (appears in fetches),
  `SamplePhotoStorageRepository`, `AddPlaceController.submit` happy path +
  failure revert (using sample repos + fake auth, mirroring the favorites
  provider tests).
- Widget: `AddPlaceScreen` form validation (required fields block save;
  price chips hidden for temples/nature/beach).
- Manual on-device (camera, gallery, map gestures, storage upload, RLS):
  add a real place end-to-end on the tablet, verify it appears on Home /
  search / Map and in `public.places` + Storage via MCP.

## Out of scope

- Photos on reviews (Phase 3b — next design)
- Address search / geocoding
- Moderation, approval queues, reporting
- Editing/deleting places from the UI (RLS permits it; UI comes later)
- Auto-fetching photos from the internet
