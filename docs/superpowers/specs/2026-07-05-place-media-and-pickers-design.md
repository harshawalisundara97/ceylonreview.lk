# Place Media & Pickers — Design

Date: 2026-07-05
Status: Approved by user

Three user-requested improvements to how places are added and reviewed in
CeylonReview:

1. District selection becomes a dropdown (Add Place).
2. The Add Place map picker gains a location search box.
3. Reviewers can attach photos to reviews, and anyone can view all of a
   place's photos.

## 1. District dropdown (Add Place)

Replace the free-text "District" `TextFormField` in
`app/lib/presentation/screens/add_place/add_place_screen.dart` with a
`DropdownButtonFormField<String>` over a fixed list of all 25 Sri Lankan
districts:

Colombo, Gampaha, Kalutara, Kandy, Matale, Nuwara Eliya, Galle, Matara,
Hambantota, Jaffna, Kilinochchi, Mannar, Vavuniya, Mullaitivu, Batticaloa,
Ampara, Trincomalee, Kurunegala, Puttalam, Anuradhapura, Polonnaruwa,
Badulla, Monaragala, Ratnapura, Kegalle.

- The list lives in a new constant file
  `app/lib/core/sri_lanka_districts.dart` (`const sriLankaDistricts =
  <String>[...]`) so other screens can reuse it.
- Validation: unchanged requirement — a district must be selected before
  save ("District is required").
- No backend change; the selected string is stored exactly as today.

## 2. Map location search (Add Place picker only)

A search box sits directly above the existing `FlutterMap` in the Add Place
form.

- **Behavior:** the user types a town or landmark ("Ella", "Galle Fort") and
  presses the search action (keyboard submit or trailing icon). The map
  animates to the top result and moves the pin there. Tapping the map to
  fine-tune, and the existing "use current location" flow, keep working
  unchanged. Search never replaces manual pinning — it only moves the map
  and pin.
- **Geocoding:** OpenStreetMap Nominatim HTTP API
  (`https://nominatim.openstreetmap.org/search?q=<query>&format=json&limit=1&countrycodes=lk`).
  - Free, no API key, works on all platforms including web, and matches the
    app's existing flutter_map/OSM stack.
  - Requests fire only on submit (never per keystroke), respecting
    Nominatim's 1 request/second usage policy.
  - A descriptive `User-Agent` header is sent on every request.
  - Results biased to Sri Lanka via `countrycodes=lk`.
- **Errors:** if no result is found or the request fails (offline), show a
  small inline "No results found" / "Search failed — check connection"
  message under the box. Failures never block manual pin-tapping.
- **Structure:** geocoding goes behind a small domain interface
  (`GeocodingRepository` with `Future<LatLng?> search(String query)`), with
  a Nominatim implementation in `data/` and a fake for tests, matching the
  app's existing repository pattern.

## 3. Review photos

### Data model & backend

- Migration: `alter table public.reviews add column photo_urls text[] not
  null default '{}';`
- Photos are stored in the existing public Supabase Storage bucket
  `place-photos`, reusing `PhotoStorageRepository.uploadPhoto/deletePhoto`
  unchanged. File names namespaced like `review-<uuid>-<n>.jpg`.
- No new table: a max of 3 photos per review does not justify a join table.
- RLS: unchanged — reviews (and their photo URLs) are publicly readable;
  only the signed-in author can insert their review. The bucket is already
  public-read.

### Write Review screen

- An "Add photos" row with camera and gallery buttons (same
  `image_picker` usage as Add Place: `maxWidth: 1600, imageQuality: 80`).
- Up to **3** photos; each picked photo shows as a removable thumbnail
  before posting. The add buttons disable at 3.
- On submit: upload photos first, then insert the review with the resulting
  URLs. If the review insert fails, delete the uploaded photos (the same
  rollback pattern `AddPlaceController` uses today).
- Upload failure surfaces as a snackbar; the typed review text and rating
  are preserved so the user can retry.

### Viewing (anyone, no auth)

- **Place detail "Photos" strip:** a horizontal scroll of all photos for the
  place — every review's photos (newest review first) plus the place's own
  `imageUrl` as the first item. Hidden when the place has no photos beyond
  a blank/missing owner image.
- **Review tiles:** each review tile shows its photos as small thumbnails
  under the text.
- **Full-screen viewer:** tapping any photo (strip or tile) opens a
  full-screen, dark-background, swipeable `PageView` with pinch-zoom
  (`InteractiveViewer`), opened at the tapped photo's index.

### Model & repositories

- `Review` gains `photoUrls: List<String>` (default `const []`).
- `SupabaseReviewsRepository` maps `photo_urls` both directions.
- `SampleReviewsRepository`/`SampleData` compile with the new field (sample
  reviews may carry empty lists).
- The reviews provider invalidation on submit is unchanged.

## Testing

- Widget test: district dropdown shows options and enforces selection.
- Widget test: search box submit moves the map/pin (fake
  `GeocodingRepository`); failure shows the inline message.
- Widget test: photo picker enforces the 3-photo limit and removable
  thumbnails.
- Widget test: photo strip renders combined photos; review tile shows its
  thumbnails; tapping opens the viewer.
- Unit test: reviews repository maps `photo_urls` both directions.

## Out of scope

- Search box on the main Map tab.
- Photo moderation/reporting, captions, or reordering.
- Migrating existing reviews (they simply have zero photos).
