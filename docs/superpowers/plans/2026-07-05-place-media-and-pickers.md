# Place Media & Pickers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a district dropdown and a map location-search box to Add Place,
and let reviewers attach up to 3 photos to a review that anyone can view in a
full-screen viewer from the place detail screen.

**Architecture:** Three independent slices on top of the existing
Flutter/Riverpod/Supabase stack: (1) a static district list feeding a
`DropdownButtonFormField`; (2) a `GeocodingRepository` abstraction backed by
the free OpenStreetMap Nominatim HTTP API, wired through the same
provider-injection seam as every other repository in this app; (3) a
`photo_urls` column on `reviews`, uploaded through the existing
`PhotoStorageRepository`/`place-photos` bucket, surfaced via a new
`PhotoViewer` full-screen widget reused by both the review tile and a new
"Photos" strip on the place detail screen.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres + Storage), flutter_map
+ latlong2, image_picker, http (new dependency for Nominatim), uuid.

## Global Constraints

- District list is exactly these 25 names, in this order: Colombo, Gampaha,
  Kalutara, Kandy, Matale, Nuwara Eliya, Galle, Matara, Hambantota, Jaffna,
  Kilinochchi, Mannar, Vavuniya, Mullaitivu, Batticaloa, Ampara, Trincomalee,
  Kurunegala, Puttalam, Anuradhapura, Polonnaruwa, Badulla, Monaragala,
  Ratnapura, Kegalle.
- Review photo limit is exactly 3 per review.
- Nominatim requests: `countrycodes=lk`, `limit=1`, a descriptive
  `User-Agent` header, and fire only on submit (never per keystroke) —
  respects the 1 request/second usage policy.
- Photo uploads reuse the existing public Supabase Storage bucket
  `place-photos` via the existing `PhotoStorageRepository` — no new bucket.
- If a review insert fails after photos were uploaded, the uploaded photos
  are deleted (same rollback pattern `AddPlaceController.submit` already
  uses).
- The place detail "Photos" strip and review-tile thumbnails are visible to
  everyone, signed in or not (no auth gate on viewing).
- The photos strip only appears when at least one review has a photo —
  never for the owner photo alone.
- Combined photos in the strip are ordered newest-review-first (the same
  order `fetchForPlace` already returns).

---

### Task 1: District dropdown in Add Place

**Files:**
- Create: `app/lib/core/sri_lanka_districts.dart`
- Modify: `app/lib/presentation/screens/add_place/add_place_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Produces: `const List<String> sriLankaDistricts` (25 items, exact order
  from Global Constraints) — importable as
  `package:ceylon_review/core/sri_lanka_districts.dart`.

- [ ] **Step 1: Write the failing test for the district constant**

Add this test inside a new top-level group, placed directly above the
existing `group('SamplePlacesRepository', ...)` in
`app/test/ceylon_review_test.dart`:

```dart
  group('sriLankaDistricts', () {
    test('contains all 25 districts with no duplicates', () {
      expect(sriLankaDistricts.length, 25);
      expect(sriLankaDistricts.toSet().length, 25);
      expect(sriLankaDistricts, contains('Colombo'));
      expect(sriLankaDistricts, contains('Jaffna'));
    });
  });

```

Add the import (alphabetical among the existing `core/` imports):

```dart
import 'package:ceylon_review/core/sri_lanka_districts.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "contains all 25 districts with no duplicates"`
Expected: FAIL — `sriLankaDistricts` is not defined.

- [ ] **Step 3: Create the district list**

Create `app/lib/core/sri_lanka_districts.dart`:

```dart
/// All 25 administrative districts of Sri Lanka, for place location pickers.
const List<String> sriLankaDistricts = <String>[
  'Colombo',
  'Gampaha',
  'Kalutara',
  'Kandy',
  'Matale',
  'Nuwara Eliya',
  'Galle',
  'Matara',
  'Hambantota',
  'Jaffna',
  'Kilinochchi',
  'Mannar',
  'Vavuniya',
  'Mullaitivu',
  'Batticaloa',
  'Ampara',
  'Trincomalee',
  'Kurunegala',
  'Puttalam',
  'Anuradhapura',
  'Polonnaruwa',
  'Badulla',
  'Monaragala',
  'Ratnapura',
  'Kegalle',
];
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "contains all 25 districts with no duplicates"`
Expected: PASS

- [ ] **Step 5: Write the failing widget test for the dropdown**

Add this test inside the existing `group('Widgets', ...)` block, directly
after the existing `testWidgets('AddPlaceScreen blocks save when required
fields missing', ...)` test:

```dart
    testWidgets(
        'AddPlaceScreen district dropdown lists all districts and satisfies '
        'validation once picked', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(themed(
        const AddPlaceScreen(),
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'user-1', name: 'Test', email: 't@example.com'))),
        ],
      ));
      await tester.pump();

      await tester.ensureVisible(find.text('Add Place'));
      await tester.tap(find.text('Add Place'));
      await tester.pump();
      expect(find.text('District is required'), findsOneWidget);

      await tester.tap(find.text('Choose a district'));
      await tester.pumpAndSettle();
      expect(find.text('Colombo'), findsWidgets);
      await tester.tap(find.text('Colombo').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add Place'));
      await tester.tap(find.text('Add Place'));
      await tester.pump();
      expect(find.text('District is required'), findsNothing);
    });

```

- [ ] **Step 6: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "district dropdown lists all districts"`
Expected: FAIL — the field is still a free-text `TextFormField`, so
`find.text('Choose a district')` finds nothing.

- [ ] **Step 7: Replace the free-text district field with a dropdown**

In `app/lib/presentation/screens/add_place/add_place_screen.dart`, add the
import (alphabetical among existing imports):

```dart
import '../../../core/sri_lanka_districts.dart';
```

Replace the field declarations (currently):

```dart
  final _districtController = TextEditingController();
```

with:

```dart
  String? _district;
```

Update `dispose()` — remove the now-deleted controller's disposal line:

```dart
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
```

Update `_submit()` — replace:

```dart
            district: _districtController.text.trim(),
```

with:

```dart
            district: _district!,
```

Replace the district `TextFormField` in `build()` — currently:

```dart
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'District is required'
                  : null,
            ),
```

with:

```dart
            DropdownButtonFormField<String>(
              value: _district,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'District'),
              hint: const Text('Choose a district'),
              items: [
                for (final d in sriLankaDistricts)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => _district = v),
              validator: (v) =>
                  v == null ? 'District is required' : null,
            ),
```

- [ ] **Step 8: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "district dropdown lists all districts"`
Expected: PASS

Also re-run the pre-existing validation test to confirm it's unaffected:

Run: `cd app && flutter test --plain-name "AddPlaceScreen blocks save when required fields missing"`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
cd app && git add lib/core/sri_lanka_districts.dart lib/presentation/screens/add_place/add_place_screen.dart test/ceylon_review_test.dart
git commit -m "Replace free-text district field with a dropdown in Add Place"
```

---

### Task 2: Nominatim geocoding + map search box in Add Place

**Files:**
- Modify: `app/pubspec.yaml`
- Create: `app/lib/domain/repositories/geocoding_repository.dart`
- Create: `app/lib/data/geocoding/nominatim_geocoding_repository.dart`
- Modify: `app/lib/application/repository_providers.dart`
- Modify: `app/lib/presentation/screens/add_place/add_place_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `abstract interface class GeocodingRepository { Future<LatLng?>
  search(String query); }` at
  `package:ceylon_review/domain/repositories/geocoding_repository.dart`;
  `final geocodingRepositoryProvider = Provider<GeocodingRepository>(...)` in
  `repository_providers.dart`, consumed by later tasks' widget tests via
  `geocodingRepositoryProvider.overrideWithValue(...)`.

- [ ] **Step 1: Add the `http` dependency**

In `app/pubspec.yaml`, add this line to the `dependencies:` block,
alphabetically after `google_fonts`:

```yaml
  http: ^1.2.2
```

Run: `cd app && flutter pub get`
Expected: `Got dependencies!` with `http` resolved, no errors.

- [ ] **Step 2: Create the `GeocodingRepository` interface**

Create `app/lib/domain/repositories/geocoding_repository.dart`:

```dart
import 'package:latlong2/latlong.dart';

/// Turns a free-text place name into map coordinates.
abstract interface class GeocodingRepository {
  /// Returns the best-match coordinates for [query], or null if nothing was
  /// found or the request failed.
  Future<LatLng?> search(String query);
}
```

- [ ] **Step 3: Create the Nominatim implementation**

Create `app/lib/data/geocoding/nominatim_geocoding_repository.dart`:

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../domain/repositories/geocoding_repository.dart';

/// Free-text search via the OpenStreetMap Nominatim public API, biased to
/// Sri Lanka. No API key; requests must fire no more than once per second
/// and carry a descriptive User-Agent per Nominatim's usage policy.
class NominatimGeocodingRepository implements GeocodingRepository {
  @override
  Future<LatLng?> search(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'lk',
    });
    final response = await http.get(uri, headers: {
      'User-Agent': 'CeylonReviewApp/1.0 (contact: harshawalisundara8@gmail.com)',
    });
    if (response.statusCode != 200) return null;

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    final lat = double.tryParse(first['lat'] as String);
    final lon = double.tryParse(first['lon'] as String);
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }
}
```

- [ ] **Step 4: Wire the provider**

In `app/lib/application/repository_providers.dart`, add the import
(alphabetical among the `data/` imports):

```dart
import '../data/geocoding/nominatim_geocoding_repository.dart';
```

and the domain import (alphabetical among the `domain/repositories/`
imports):

```dart
import '../domain/repositories/geocoding_repository.dart';
```

Add the provider at the end of the file:

```dart

final geocodingRepositoryProvider = Provider<GeocodingRepository>(
    (ref) => NominatimGeocodingRepository());
```

- [ ] **Step 5: Write the failing widget test for the search box**

Add this test inside `group('Widgets', ...)`, directly after the district
dropdown test added in Task 1:

```dart
    testWidgets(
        'AddPlaceScreen search box moves the pin on a match and shows an '
        'error when nothing is found', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(themed(
        const AddPlaceScreen(),
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'user-1', name: 'Test', email: 't@example.com'))),
          geocodingRepositoryProvider
              .overrideWithValue(_FakeGeocodingRepository()),
        ],
      ));
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('locationSearchField')));
      await tester.enterText(
          find.byKey(const Key('locationSearchField')), 'Ella');
      await tester.tap(find.byKey(const Key('locationSearchButton')));
      await tester.pump();
      expect(find.byIcon(Icons.location_pin), findsOneWidget);
      expect(find.textContaining('No results found'), findsNothing);

      await tester.enterText(
          find.byKey(const Key('locationSearchField')), 'Nowhereville');
      await tester.tap(find.byKey(const Key('locationSearchButton')));
      await tester.pump();
      expect(find.text('No results found for "Nowhereville".'),
          findsOneWidget);
    });

```

Add the `_FakeGeocodingRepository` fake class at the bottom of the file,
directly after the existing `_FakeAuthNotifier` class:

```dart

class _FakeGeocodingRepository implements GeocodingRepository {
  @override
  Future<LatLng?> search(String query) async {
    if (query == 'Ella') return const LatLng(6.8667, 81.0466);
    return null;
  }
}
```

Add these imports (alphabetical among existing imports):

```dart
import 'package:ceylon_review/domain/repositories/geocoding_repository.dart';
import 'package:latlong2/latlong.dart';
```

- [ ] **Step 6: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "search box moves the pin"`
Expected: FAIL — no widget with `Key('locationSearchField')` exists yet.

- [ ] **Step 7: Add the search box and wire it to the map**

In `app/lib/presentation/screens/add_place/add_place_screen.dart`, add the
import (alphabetical among existing imports):

```dart
import '../../../application/repository_providers.dart';
```

Add state fields directly below the existing `bool _submitting = false;`
line:

```dart
  final _mapController = MapController();
  final _searchController = TextEditingController();
  bool _searching = false;
  String? _searchError;
```

Update `dispose()` to also dispose the new controller:

```dart
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }
```

Add a new method directly after `_useCurrentLocation()`:

```dart
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final result =
          await ref.read(geocodingRepositoryProvider).search(query);
      if (result == null) {
        setState(() => _searchError = 'No results found for "$query".');
        return;
      }
      setState(() => _pin = result);
      _mapController.move(result, 13);
    } catch (_) {
      setState(() => _searchError = 'Search failed — check your connection.');
    } finally {
      setState(() => _searching = false);
    }
  }
```

Add the search box above the map, and attach the controller to `FlutterMap`.
Replace:

```dart
            Text('Location — tap the map or use your position',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
```

with:

```dart
            Text('Location — tap the map or use your position',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('locationSearchField'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search a town or landmark',
                      hintText: 'e.g. Ella, Galle Fort',
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  key: const Key('locationSearchButton'),
                  icon: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search_rounded),
                  onPressed: _searching ? null : _searchLocation,
                ),
              ],
            ),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(_searchError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
```

- [ ] **Step 8: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "search box moves the pin"`
Expected: PASS

- [ ] **Step 9: Commit**

```bash
cd app && git add pubspec.yaml pubspec.lock lib/domain/repositories/geocoding_repository.dart lib/data/geocoding/nominatim_geocoding_repository.dart lib/application/repository_providers.dart lib/presentation/screens/add_place/add_place_screen.dart test/ceylon_review_test.dart
git commit -m "Add Nominatim-backed location search to the Add Place map picker"
```

---

### Task 3: `photoUrls` on the Review model and repositories

**Files:**
- Modify: `app/lib/domain/models/review.dart`
- Modify: `app/lib/domain/repositories/reviews_repository.dart`
- Modify: `app/lib/data/supabase/supabase_reviews_repository.dart`
- Modify: `app/lib/data/sample/sample_reviews_repository.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: nothing from Tasks 1–2.
- Produces: `Review.photoUrls` (`List<String>`, default `const []`);
  `ReviewsRepository.add(..., {List<String> photoUrls = const []})` — Task 5
  (ReviewSubmitter) and Task 6 (Write Review screen) call this signature.

- [ ] **Step 1: Write the failing test for the round trip**

Add this test inside the existing `group('SampleReviewsRepository', ...)`,
directly after the existing `test('added review appears for its place,
newest first', ...)`:

```dart
    test('add() stores photoUrls and fetchForPlace returns them', () async {
      final repo = SampleReviewsRepository(seed: []);
      final added = await repo.add(
        placeId: 'ministry-of-crab',
        authorName: 'Nadeesha Perera',
        rating: 5,
        text: 'Loved the crab curry and the service.',
        photoUrls: const ['https://photos.example/crab-1.jpg'],
      );
      expect(added.photoUrls, ['https://photos.example/crab-1.jpg']);

      final stored = await repo.fetchForPlace('ministry-of-crab');
      expect(stored.single.photoUrls, ['https://photos.example/crab-1.jpg']);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "stores photoUrls and fetchForPlace returns them"`
Expected: FAIL — `photoUrls` named parameter does not exist on `add()`.

- [ ] **Step 3: Add `photoUrls` to the `Review` model**

Replace the full contents of `app/lib/domain/models/review.dart`:

```dart
/// An immutable user review of a place.
class Review {
  const Review({
    required this.id,
    required this.placeId,
    required this.authorName,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.photoUrls = const [],
  });

  final String id;
  final String placeId;
  final String authorName;
  final int rating; // 1..5 whole stars
  final String text;
  final DateTime createdAt;

  /// Public URLs of photos the reviewer attached (0–3).
  final List<String> photoUrls;
}
```

- [ ] **Step 4: Add `photoUrls` to the `ReviewsRepository` interface**

Replace the full contents of
`app/lib/domain/repositories/reviews_repository.dart`:

```dart
import '../models/review.dart';

/// Read/write access to reviews for places.
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
}
```

- [ ] **Step 5: Update `SampleReviewsRepository`**

In `app/lib/data/sample/sample_reviews_repository.dart`, replace the `add`
method:

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
```

- [ ] **Step 6: Update `SupabaseReviewsRepository`**

In `app/lib/data/supabase/supabase_reviews_repository.dart`, replace the
`add` method:

```dart
  @override
  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
    List<String> photoUrls = const [],
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to write a review.');
    }
    final row = await _client
        .from('reviews')
        .insert({
          'place_id': placeId,
          'user_id': userId,
          'author_name': authorName,
          'rating': rating,
          'text': text,
          'photo_urls': photoUrls,
        })
        .select()
        .single();
    return _reviewFromRow(row);
  }
```

and replace `_reviewFromRow`:

```dart
Review _reviewFromRow(Map<String, dynamic> row) => Review(
      id: row['id'] as String,
      placeId: row['place_id'] as String,
      authorName: row['author_name'] as String,
      rating: row['rating'] as int,
      text: row['text'] as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      photoUrls: (row['photo_urls'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
```

- [ ] **Step 7: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "stores photoUrls and fetchForPlace returns them"`
Expected: PASS

Also run the full suite to confirm nothing else broke from the model change:

Run: `cd app && flutter test`
Expected: all tests PASS (the model change is additive with a default value,
so no other test should reference a broken constructor call).

- [ ] **Step 8: Commit**

```bash
cd app && git add lib/domain/models/review.dart lib/domain/repositories/reviews_repository.dart lib/data/sample/sample_reviews_repository.dart lib/data/supabase/supabase_reviews_repository.dart test/ceylon_review_test.dart
git commit -m "Add photoUrls to Review model and reviews repositories"
```

---

### Task 4: Supabase migration — `reviews.photo_urls` column

**Files:**
- Modify: `docs/BACKEND_PLAN.md` (schema reference doc)
- No app code changes.

**Interfaces:**
- Consumes: nothing.
- Produces: a live `photo_urls text[] not null default '{}'` column on the
  Supabase `public.reviews` table, which Task 3's `SupabaseReviewsRepository`
  (already implemented) reads and writes.

- [ ] **Step 1: Run the migration against the live Supabase project**

If a Supabase MCP tool (e.g. `execute_sql`) is available this session, use
it to run:

```sql
alter table public.reviews
  add column photo_urls text[] not null default '{}';
```

If no MCP database tool is available, print this exact SQL block to the
user and ask them to run it in the Supabase SQL editor, then wait for their
confirmation before proceeding (this project's established pattern — see
`docs/BACKEND_PLAN.md`'s "Live deployment status" note about prior
migrations being applied this way).

- [ ] **Step 2: Verify the column exists**

Run this query (via MCP `execute_sql` or ask the user to run it and paste
the result):

```sql
select column_name, data_type, column_default
from information_schema.columns
where table_name = 'reviews' and column_name = 'photo_urls';
```

Expected: one row — `photo_urls | ARRAY | '{}'::text[]`.

- [ ] **Step 3: Update the schema reference doc**

In `docs/BACKEND_PLAN.md`, inside the `create table public.reviews (...)`
block, add a line directly after the `text` column's line
(`text text not null check (char_length(text) >= 10),`):

```sql
  photo_urls text[] not null default '{}',       -- up to 3 review photos
```

- [ ] **Step 4: Commit**

```bash
git add docs/BACKEND_PLAN.md
git commit -m "Document the reviews.photo_urls migration"
```

---

### Task 5: `ReviewSubmitter` uploads and rolls back review photos

**Files:**
- Modify: `app/lib/application/reviews_provider.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `ReviewsRepository.add(..., photoUrls)` from Task 3;
  `PhotoStorageRepository.uploadPhoto`/`deletePhoto` (existing, unchanged).
- Produces: `ReviewSubmitter.submit({..., List<Uint8List> photoBytes =
  const []})` — Task 6 (Write Review screen UI) calls this with up to 3
  entries.

- [ ] **Step 1: Write the failing tests**

Add a new group at the end of `main()`'s body, directly after the existing
`group('AddPlaceController', ...)` block:

```dart
  group('ReviewSubmitter', () {
    test('submit uploads photos, stores them on the review, and cleans up '
        'nothing on success', () async {
      final reviewsRepo = SampleReviewsRepository(seed: []);
      final photoRepo = SamplePhotoStorageRepository();
      final container = ProviderContainer(overrides: [
        reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
        photoStorageRepositoryProvider.overrideWithValue(photoRepo),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
      ]);
      addTearDown(container.dispose);

      await container.read(reviewSubmitterProvider).submit(
            placeId: 'ministry-of-crab',
            rating: 5,
            text: 'Wonderful crab curry and warm service all evening.',
            photoBytes: [Uint8List.fromList([1, 2, 3])],
          );

      final stored = await reviewsRepo.fetchForPlace('ministry-of-crab');
      expect(stored.single.photoUrls, hasLength(1));
      expect(photoRepo.uploads, hasLength(1));
    });

    test('submit deletes uploaded photos if the review insert fails',
        () async {
      final photoRepo = SamplePhotoStorageRepository();
      final container = ProviderContainer(overrides: [
        reviewsRepositoryProvider.overrideWithValue(_ThrowingReviewsRepository()),
        photoStorageRepositoryProvider.overrideWithValue(photoRepo),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
      ]);
      addTearDown(container.dispose);

      await expectLater(
        container.read(reviewSubmitterProvider).submit(
              placeId: 'ministry-of-crab',
              rating: 5,
              text: 'Wonderful crab curry and warm service all evening.',
              photoBytes: [Uint8List.fromList([1, 2, 3])],
            ),
        throwsA(isA<StateError>()),
      );
      expect(photoRepo.uploads, isEmpty);
    });
  });

```

Add the `_ThrowingReviewsRepository` fake at the bottom of the file, directly
after the existing `_ThrowingPlacesRepository` class:

```dart

class _ThrowingReviewsRepository implements ReviewsRepository {
  @override
  Future<Review> add({
    required String placeId,
    required String authorName,
    required int rating,
    required String text,
    List<String> photoUrls = const [],
  }) async {
    throw StateError('insert failed');
  }

  @override
  Future<List<Review>> fetchForPlace(String placeId) async => [];

  @override
  Future<List<Review>> fetchMine() async => [];
}
```

Add these imports (alphabetical among existing imports):

```dart
import 'package:ceylon_review/application/reviews_provider.dart';
import 'package:ceylon_review/domain/models/review.dart';
import 'package:ceylon_review/domain/repositories/reviews_repository.dart';
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name "ReviewSubmitter"`
Expected: FAIL — `submit()` has no `photoBytes` parameter yet.

- [ ] **Step 3: Implement upload + rollback in `ReviewSubmitter.submit`**

In `app/lib/application/reviews_provider.dart`, add these imports at the top
(alphabetical, above the existing `package:flutter_riverpod` import):

```dart
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
```

Replace the `ReviewSubmitter.submit` method:

```dart
  Future<void> submit({
    required String placeId,
    required int rating,
    required String text,
    List<Uint8List> photoBytes = const [],
  }) async {
    final user = _ref.read(authProvider);
    if (photoBytes.isNotEmpty && user == null) {
      throw StateError('You must be signed in to add photos to a review.');
    }
    final batchId = const Uuid().v4();
    final uploadedUrls = <String>[];
    try {
      for (var i = 0; i < photoBytes.length; i++) {
        final url = await _ref.read(photoStorageRepositoryProvider).uploadPhoto(
              photoBytes[i],
              fileName: '${user!.id}/$batchId-$i.jpg',
            );
        uploadedUrls.add(url);
      }
      await _ref.read(reviewsRepositoryProvider).add(
            placeId: placeId,
            authorName: user?.name ?? 'Traveller',
            rating: rating,
            text: text,
            photoUrls: uploadedUrls,
          );
    } catch (_) {
      for (final url in uploadedUrls) {
        await _ref
            .read(photoStorageRepositoryProvider)
            .deletePhoto(url)
            .catchError((_) {});
      }
      rethrow;
    }
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
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd app && flutter test --plain-name "ReviewSubmitter"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd app && git add lib/application/reviews_provider.dart test/ceylon_review_test.dart
git commit -m "Upload and roll back review photos in ReviewSubmitter"
```

---

### Task 6: Write Review screen — photo picker (up to 3)

**Files:**
- Modify: `app/lib/presentation/screens/write_review/write_review_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `ReviewSubmitter.submit({..., photoBytes})` from Task 5.
- Produces: nothing further consumed by later tasks.

This app has no existing precedent for driving `image_picker`'s native
camera/gallery flow inside a widget test (`AddPlaceScreen`'s own single-photo
picker has zero test coverage of the picking interaction itself, for the
same reason: it opens a real platform picker that can't run headless).
Consistent with that boundary, this task's test exercises everything that
doesn't require actually invoking the picker — the section renders, and a
review posts successfully with no photos attached. The upload and rollback
behavior once photos exist is fully covered at the `ReviewSubmitter` level
in Task 5, which doesn't depend on `image_picker`. The 3-photo cap and
thumbnail removal are UI-only logic (`_photoBytes.length >= 3` disabling the
buttons, `_removePhoto` splicing the list) exercised by manual smoke-testing
in Task 9 rather than an automated widget test, since reaching that state
requires the real picker.

- [ ] **Step 1: Write the failing widget test**

Add this test inside `group('Widgets', ...)`, directly after the last
`LeaderboardScreen` test:

```dart
    testWidgets(
        'WriteReviewScreen shows an Add photos section and posts a review '
        'without photos', (tester) async {
      final reviewsRepo = SampleReviewsRepository(seed: []);
      await tester.pumpWidget(themed(
        const WriteReviewScreen(initialPlaceId: 'ministry-of-crab'),
        overrides: [
          placesRepositoryProvider.overrideWithValue(SamplePlacesRepository()),
          reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add photos (optional, up to 3)'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);

      await tester.tap(find.byType(IconButton).at(4));
      await tester.enterText(find.byType(TextField),
          'Wonderful crab curry and warm service all evening.');
      await tester.ensureVisible(find.text('Post Review'));
      await tester.tap(find.text('Post Review'));
      await tester.pumpAndSettle();

      final stored = await reviewsRepo.fetchForPlace('ministry-of-crab');
      expect(stored, hasLength(1));
      expect(stored.single.photoUrls, isEmpty);
    });

```

Add these imports (alphabetical among existing imports):

```dart
import 'package:ceylon_review/presentation/screens/write_review/write_review_screen.dart';
```

(`placesRepositoryProvider` and `reviewsRepositoryProvider` already come
from the existing `repository_providers.dart` import.)

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "shows an Add photos section"`
Expected: FAIL — no "Add photos" text exists yet.

- [ ] **Step 3: Add the photo picker UI**

In `app/lib/presentation/screens/write_review/write_review_screen.dart`, add
these imports (alphabetical among existing imports):

```dart
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
```

Add a state field directly below the existing `bool _posting = false;`:

```dart
  final List<Uint8List> _photoBytes = [];
```

Add these methods directly after `dispose()`:

```dart
  Future<void> _pickPhoto(ImageSource source) async {
    if (_photoBytes.length >= 3) return;
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoBytes.add(bytes));
  }

  void _removePhoto(int index) => setState(() => _photoBytes.removeAt(index));
```

Update the call to `submit` inside `_post()` — replace:

```dart
      await ref.read(reviewSubmitterProvider).submit(
            placeId: _placeId!,
            rating: _rating,
            text: _text.text.trim(),
          );
```

with:

```dart
      await ref.read(reviewSubmitterProvider).submit(
            placeId: _placeId!,
            rating: _rating,
            text: _text.text.trim(),
            photoBytes: _photoBytes,
          );
```

Update the success-reset branch inside `_post()` — replace:

```dart
        setState(() {
          _rating = 0;
          _text.clear();
          if (widget.initialPlaceId == null) _placeId = null;
        });
```

with:

```dart
        setState(() {
          _rating = 0;
          _text.clear();
          _photoBytes.clear();
          if (widget.initialPlaceId == null) _placeId = null;
        });
```

Add the photo picker section in `build()`, between the rating `StarPicker`
block and the "Your review" text field. Replace:

```dart
            const SizedBox(height: AppSpacing.xl),
            Text('Your review', style: theme.textTheme.titleMedium),
```

with:

```dart
            const SizedBox(height: AppSpacing.xl),
            Text('Add photos (optional, up to 3)',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_rounded),
                    label: const Text('Camera'),
                    onPressed: _photoBytes.length >= 3
                        ? null
                        : () => _pickPhoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                    onPressed: _photoBytes.length >= 3
                        ? null
                        : () => _pickPhoto(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_photoBytes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoBytes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_photoBytes[i],
                            width: 72, height: 72, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removePhoto(i),
                          child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Your review', style: theme.textTheme.titleMedium),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "shows an Add photos section"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd app && git add lib/presentation/screens/write_review/write_review_screen.dart test/ceylon_review_test.dart
git commit -m "Let reviewers attach up to 3 photos on Write Review"
```

---

### Task 7: `PhotoViewer` widget + review tile thumbnails

**Files:**
- Create: `app/lib/presentation/widgets/photo_viewer.dart`
- Modify: `app/lib/presentation/widgets/review_tile.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `Review.photoUrls` from Task 3.
- Produces: `PhotoViewer.open(context, {required List<String> photoUrls,
  required int initialIndex})` — Task 8 (place detail Photos strip) reuses
  this static method.

- [ ] **Step 1: Write the failing widget test**

Add this test inside `group('Widgets', ...)`, directly after the
`WriteReviewScreen` test added in Task 6:

```dart
    testWidgets(
        'ReviewTile shows photo thumbnails and opens the full-screen viewer '
        'on tap', (tester) async {
      final review = Review(
        id: 'r1',
        placeId: 'ministry-of-crab',
        authorName: 'Nadeesha Perera',
        rating: 5,
        text: 'Loved it!',
        createdAt: DateTime(2026, 5, 18),
        photoUrls: const [
          'https://photos.example/one.jpg',
          'https://photos.example/two.jpg',
        ],
      );

      await tester.pumpWidget(themed(ReviewTile(review: review)));
      await tester.pump();

      expect(find.byType(Image), findsNWidgets(2));

      await tester.tap(find.byType(Image).first);
      await tester.pumpAndSettle();

      expect(find.byType(PhotoViewer), findsOneWidget);
    });

```

Add these imports (alphabetical among existing imports):

```dart
import 'package:ceylon_review/presentation/widgets/photo_viewer.dart';
import 'package:ceylon_review/presentation/widgets/review_tile.dart';
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test --plain-name "ReviewTile shows photo thumbnails"`
Expected: FAIL — `PhotoViewer` does not exist, and `ReviewTile` doesn't
render photos yet.

- [ ] **Step 3: Create `PhotoViewer`**

Create `app/lib/presentation/widgets/photo_viewer.dart`:

```dart
import 'package:flutter/material.dart';

/// Full-screen, swipeable, pinch-zoomable viewer for a list of photo URLs.
/// Used by review thumbnails and the place detail Photos strip.
class PhotoViewer extends StatelessWidget {
  const PhotoViewer(
      {super.key, required this.photoUrls, required this.initialIndex});

  final List<String> photoUrls;
  final int initialIndex;

  static void open(BuildContext context,
      {required List<String> photoUrls, required int initialIndex}) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          PhotoViewer(photoUrls: photoUrls, initialIndex: initialIndex),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photoUrls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              photoUrls[i],
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Add thumbnails to `ReviewTile`**

In `app/lib/presentation/widgets/review_tile.dart`, add the import
(alphabetical among the existing relative imports):

```dart
import 'photo_viewer.dart';
```

Replace the closing of `build()` — currently:

```dart
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
```

with:

```dart
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: theme.textTheme.bodyMedium),
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => PhotoViewer.open(context,
                      photoUrls: review.photoUrls, initialIndex: i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.photoUrls[i],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 64,
                        height: 64,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd app && flutter test --plain-name "ReviewTile shows photo thumbnails"`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
cd app && git add lib/presentation/widgets/photo_viewer.dart lib/presentation/widgets/review_tile.dart test/ceylon_review_test.dart
git commit -m "Add full-screen PhotoViewer and review tile thumbnails"
```

---

### Task 8: Place detail "Photos" strip

**Files:**
- Modify: `app/lib/presentation/screens/place_detail/place_detail_screen.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `PhotoViewer.open(...)` from Task 7; `Review.photoUrls` from
  Task 3; the existing `reviewsForPlaceProvider` (unchanged signature).
- Produces: nothing further consumed by later tasks.

- [ ] **Step 1: Write the failing widget test**

Add this test inside `group('Widgets', ...)`, directly after the
`ReviewTile` test added in Task 7:

```dart
    testWidgets(
        'PlaceDetailScreen shows a Photos strip built from review photos',
        (tester) async {
      final reviewsRepo = SampleReviewsRepository(seed: [
        Review(
          id: 'r1',
          placeId: 'ministry-of-crab',
          authorName: 'Nadeesha Perera',
          rating: 5,
          text: 'Loved it!',
          createdAt: DateTime(2026, 5, 18),
          photoUrls: const ['https://photos.example/crab.jpg'],
        ),
      ]);

      await tester.pumpWidget(themed(
        const PlaceDetailScreen(placeId: 'ministry-of-crab'),
        overrides: [
          placesRepositoryProvider.overrideWithValue(SamplePlacesRepository()),
          reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
          favoritesRepositoryProvider
              .overrideWithValue(SampleFavoritesRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Photos'), findsOneWidget);
    });

    testWidgets(
        'PlaceDetailScreen hides the Photos strip when no review has a photo',
        (tester) async {
      final reviewsRepo = SampleReviewsRepository(seed: [
        Review(
          id: 'r1',
          placeId: 'ministry-of-crab',
          authorName: 'Nadeesha Perera',
          rating: 5,
          text: 'Loved it!',
          createdAt: DateTime(2026, 5, 18),
        ),
      ]);

      await tester.pumpWidget(themed(
        const PlaceDetailScreen(placeId: 'ministry-of-crab'),
        overrides: [
          placesRepositoryProvider.overrideWithValue(SamplePlacesRepository()),
          reviewsRepositoryProvider.overrideWithValue(reviewsRepo),
          favoritesRepositoryProvider
              .overrideWithValue(SampleFavoritesRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Photos'), findsNothing);
    });

```

Add these imports (alphabetical among existing imports):

```dart
import 'package:ceylon_review/presentation/screens/place_detail/place_detail_screen.dart';
```

(`Review`, `SampleReviewsRepository`, `favoritesRepositoryProvider`,
`SampleFavoritesRepository`, `reviewsRepositoryProvider`,
`placesRepositoryProvider`, `SamplePlacesRepository` are all already
imported by earlier tasks/tests.)

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd app && flutter test --plain-name "Photos strip"`
Expected: FAIL — `PlaceDetailScreen` doesn't render a "Photos" section yet.

- [ ] **Step 3: Add the Photos strip**

In `app/lib/presentation/screens/place_detail/place_detail_screen.dart`, add
the import (alphabetical among existing relative imports):

```dart
import '../../widgets/photo_viewer.dart';
```

Replace the `reviews.when(...)` block — currently:

```dart
                  reviews.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text('Could not load reviews.'),
                    ),
                    data: (list) => list.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg),
                            child: Text(
                              'No reviews yet — be the first to share your visit!',
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : Column(
                            children: [
                              for (final review in list)
                                ReviewTile(review: review),
                            ],
                          ),
                  ),
```

with:

```dart
                  reviews.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Text('Could not load reviews.'),
                    ),
                    data: (list) {
                      final reviewPhotos = [
                        for (final r in list) ...r.photoUrls,
                      ];
                      final photos = [
                        if (place.imageUrl.isNotEmpty) place.imageUrl,
                        ...reviewPhotos,
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reviewPhotos.isNotEmpty) ...[
                            Text('Photos', style: theme.textTheme.titleLarge),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              height: 96,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: photos.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (_, i) => GestureDetector(
                                  onTap: () => PhotoViewer.open(context,
                                      photoUrls: photos, initialIndex: i),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      photos[i],
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 96,
                                        height: 96,
                                        color: theme
                                            .colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (list.isEmpty)
                            Text(
                              'No reviews yet — be the first to share your visit!',
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            Column(
                              children: [
                                for (final review in list)
                                  ReviewTile(review: review),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd app && flutter test --plain-name "Photos strip"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd app && git add lib/presentation/screens/place_detail/place_detail_screen.dart test/ceylon_review_test.dart
git commit -m "Add a Photos strip to place detail, sourced from review photos"
```

---

### Task 9: Final verification pass

**Files:** none (verification only).

**Interfaces:** none.

- [ ] **Step 1: Run static analysis**

Run: `cd app && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run the full test suite**

Run: `cd app && flutter test`
Expected: every test passes (this now includes all tests added in Tasks
1–8, plus the full pre-existing suite).

- [ ] **Step 3: Manual smoke check**

Run the app (`flutter run -d chrome` or a connected device/simulator) and
confirm by hand:
- Add a Place → District field is a dropdown; searching "Ella" in the new
  search box moves the map pin there.
- Write a Review → attach 2 photos, remove one, post with 1 photo.
- Open that place's detail screen → a "Photos" strip appears above Reviews;
  tapping a photo (strip or review tile) opens the full-screen swipeable
  viewer.

- [ ] **Step 4: Commit** (only if Step 3 required any follow-up fixes; if
  everything already passed in Tasks 1–8, there is nothing new to commit
  and this step is skipped)
