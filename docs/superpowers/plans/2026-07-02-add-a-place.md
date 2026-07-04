# Add a Place (Phase 3a) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Signed-in users can add a missing place — full details, a map-pinned location, and a camera/gallery photo — which becomes public immediately and reviewable like any seeded place.

**Architecture:** Community places are rows in the existing `places` table with a new nullable `added_by` column, so every existing screen/provider works on them unchanged. Photos go to a new public Supabase Storage bucket `place-photos` via a new `PhotoStorageRepository` (three-file pattern, reused by Phase 3b). An `AddPlaceController` AsyncNotifier orchestrates upload → insert → provider invalidation.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres + Storage), flutter_map, geolocator (existing), image_picker, uuid (new).

**Spec:** `docs/superpowers/specs/2026-07-02-add-a-place-design.md`. One deliberate refinement: the spec lists `flutter_image_compress`, but `image_picker` natively resizes/compresses (`maxWidth: 1600, imageQuality: 80`), so we skip the extra dependency (YAGNI).

## Global Constraints

- New places are public immediately; badge "Community" wherever `place.addedBy != null` (PlaceCard and place detail only).
- Add-place entry points are exactly two: the home-screen search empty state and a FAB on the Map tab. Both visible only when signed in (`authProvider` non-null).
- Location is picked via map pin (tap) or "Use my current location" — no geocoding/address search.
- Photo: max one per place, optional; camera or gallery; resized to max 1600px, JPEG quality 80, via `image_picker` parameters.
- Storage object path MUST be `<uid>/<uuid>.jpg` inside bucket `place-photos` (RLS depends on the first folder segment).
- Match the existing three-file repository pattern and provider style exactly; `SupabasePlacesRepository.addPlace` throws `StateError('You must be signed in to add a place.')` when signed out (same convention as favorites).
- Place `id` for community places is `const Uuid().v4()`; new rows insert `rating: 0, review_count: 0, trending: false`.
- All commits on branch `2026-07-02-add-a-place`; run `flutter analyze` (expect "No issues found!") before every commit.

---

### Task 1: Supabase backend — `added_by` column, RLS, storage bucket

**Files:** none in the repo — applied to Supabase project `jrepeqykdgsckrlvujnt` via MCP tools.

**Interfaces:**
- Produces: `places.added_by uuid` column; insert/update/delete RLS on `places`; bucket `place-photos` with folder-scoped write policies.

- [ ] **Step 1: Apply schema migration** via `apply_migration` (name `add_added_by_to_places`):

```sql
alter table public.places
  add column added_by uuid references public.profiles(id);

create policy "Authenticated users can add places"
  on public.places for insert to authenticated
  with check (added_by = auth.uid());

create policy "Creators can update their places"
  on public.places for update to authenticated
  using (added_by = auth.uid());

create policy "Creators can delete their places"
  on public.places for delete to authenticated
  using (added_by = auth.uid());
```

- [ ] **Step 2: Create the storage bucket + policies** via `apply_migration` (name `create_place_photos_bucket`):

```sql
insert into storage.buckets (id, name, public)
values ('place-photos', 'place-photos', true);

create policy "Public read for place photos"
  on storage.objects for select
  using (bucket_id = 'place-photos');

create policy "Users upload into their own folder"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'place-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users delete from their own folder"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'place-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
```

- [ ] **Step 3: Verify** — `execute_sql`: `select column_name from information_schema.columns where table_name = 'places' and column_name = 'added_by';` returns one row; `select id, public from storage.buckets where id = 'place-photos';` returns `public = true`. Run `get_advisors` (security): no NEW warnings beyond the pre-existing `auth_leaked_password_protection`.

---

### Task 2: `Place.addedBy` + `AppUser.id` + Supabase mapping

**Files:**
- Modify: `app/lib/domain/models/place.dart` (constructor + field)
- Modify: `app/lib/domain/models/user.dart` (add `id`)
- Modify: `app/lib/data/supabase/supabase_places_repository.dart:53-68` (`_placeFromRow`)
- Modify: `app/lib/data/supabase/supabase_auth_repository.dart:60-68` (`_toAppUser`)
- Modify: `app/lib/data/sample/sample_auth_repository.dart:24,37` (constructor calls)
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Produces: `Place.addedBy` (`String?`, null for seeded places) and `AppUser.id` (`String`, required — the Supabase auth uid). Every later task reads these fields.

- [ ] **Step 1: Write the failing test** — in the existing `Place formatting` group's file, add a new group:

```dart
group('Place addedBy', () {
  test('defaults to null and carries a value when set', () {
    const seeded = Place(
      id: 'x', name: 'X', category: PlaceCategory.food, district: 'Colombo',
      latitude: 6.9, longitude: 79.8, rating: 4, reviewCount: 1,
      description: 'd', imageUrl: 'u',
    );
    const community = Place(
      id: 'y', name: 'Y', category: PlaceCategory.food, district: 'Colombo',
      latitude: 6.9, longitude: 79.8, rating: 0, reviewCount: 0,
      description: 'd', imageUrl: 'u', addedBy: 'user-1',
    );
    expect(seeded.addedBy, isNull);
    expect(community.addedBy, 'user-1');
  });
});
```

- [ ] **Step 2: Run** `cd app && flutter test test/ceylon_review_test.dart` — expect FAIL (no `addedBy` parameter).

- [ ] **Step 3: Implement** — in `place.dart` add `this.addedBy,` to the constructor (after `this.closesAt,`) and the field with doc comment:

```dart
  /// Id of the user who added this place; null for seeded places.
  final String? addedBy;
```

In `supabase_places_repository.dart`, add to `_placeFromRow`:

```dart
      addedBy: row['added_by'] as String?,
```

Then add `id` to `AppUser` (`user.dart`):

```dart
  const AppUser({required this.id, required this.name, required this.email});

  /// The auth user id (Supabase `auth.users.id`).
  final String id;
```

Update every construction site:
- `supabase_auth_repository.dart` `_toAppUser`: add `id: user.id,` to the `AppUser(...)` call.
- `sample_auth_repository.dart` line 24: `AppUser(id: 'sample-user', name: name.isEmpty ? 'Traveller' : name, email: email)`; line 37: `AppUser(id: 'sample-user', name: name.trim(), email: email)`.
- `test/ceylon_review_test.dart` lines 99 and 164: add `id: 'user-1',` to both `const AppUser(...)` constructions.

- [ ] **Step 4: Run** the suite — all tests pass. `flutter analyze` clean.

- [ ] **Step 5: Commit** — `git add app/lib/domain/models/ app/lib/data/ app/test/ && git commit -m "Add Place.addedBy and AppUser.id"`

---

### Task 3: `PlacesRepository.addPlace`

**Files:**
- Modify: `app/lib/domain/repositories/places_repository.dart`
- Modify: `app/lib/data/sample/sample_places_repository.dart`
- Modify: `app/lib/data/supabase/supabase_places_repository.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `Place.addedBy` (Task 2).
- Produces: `Future<Place> addPlace(Place place)` on `PlacesRepository`.

- [ ] **Step 1: Write the failing test** (in the `SamplePlacesRepository` group):

```dart
test('addPlace makes the place visible in fetches', () async {
  final repo = SamplePlacesRepository();
  const place = Place(
    id: 'new-cafe', name: 'New Cafe', category: PlaceCategory.food,
    district: 'Galle', latitude: 6.03, longitude: 80.22,
    rating: 0, reviewCount: 0, description: 'Cozy.', imageUrl: '',
    addedBy: 'user-1',
  );
  final created = await repo.addPlace(place);
  expect(created.id, 'new-cafe');
  expect((await repo.fetchAll()).map((p) => p.id), contains('new-cafe'));
  expect(await repo.fetchById('new-cafe'), isNotNull);
});
```

- [ ] **Step 2: Run it** — FAIL (`addPlace` not defined).

- [ ] **Step 3: Implement.** Interface (`places_repository.dart`):

```dart
  /// Adds a community place and returns it as stored.
  Future<Place> addPlace(Place place);
```

`SamplePlacesRepository`: change the field to a growable copy so adding works —

```dart
  SamplePlacesRepository({List<Place>? places})
      : _places = [...(places ?? SampleData.places)];
```

and add:

```dart
  @override
  Future<Place> addPlace(Place place) async {
    _places.add(place);
    return place;
  }
```

`SupabasePlacesRepository`:

```dart
  @override
  Future<Place> addPlace(Place place) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to add a place.');
    }
    final row = await _client
        .from('places')
        .insert({
          'id': place.id,
          'name': place.name,
          'category': place.category.name,
          'district': place.district,
          'latitude': place.latitude,
          'longitude': place.longitude,
          'rating': 0,
          'review_count': 0,
          'description': place.description,
          'image_url': place.imageUrl,
          'trending': false,
          'price_level': place.priceLevel,
          'opens_at': place.opensAt,
          'closes_at': place.closesAt,
          'added_by': userId,
        })
        .select()
        .single();
    return _placeFromRow(row);
  }
```

- [ ] **Step 4: Run** suite + `flutter analyze` — pass/clean.

- [ ] **Step 5: Commit** — `git commit -m "Add addPlace to places repositories"` (with the four files).

---

### Task 4: `PhotoStorageRepository` (three-file pattern) + provider

**Files:**
- Create: `app/lib/domain/repositories/photo_storage_repository.dart`
- Create: `app/lib/data/sample/sample_photo_storage_repository.dart`
- Create: `app/lib/data/supabase/supabase_photo_storage_repository.dart`
- Modify: `app/lib/application/repository_providers.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Produces: `PhotoStorageRepository.uploadPhoto(Uint8List bytes, {required String fileName}) → Future<String>` (public URL), `deletePhoto(String url)`, and `photoStorageRepositoryProvider`.

- [ ] **Step 1: Write the failing test:**

```dart
group('SamplePhotoStorageRepository', () {
  test('uploadPhoto returns a url and records the upload', () async {
    final repo = SamplePhotoStorageRepository();
    final url = await repo.uploadPhoto(Uint8List.fromList([1, 2, 3]),
        fileName: 'user-1/abc.jpg');
    expect(url, contains('user-1/abc.jpg'));
    expect(repo.uploads.keys, contains('user-1/abc.jpg'));
    await repo.deletePhoto(url);
    expect(repo.uploads, isEmpty);
  });
});
```

(add `import 'dart:typed_data';` to the test file if missing)

- [ ] **Step 2: Run it** — FAIL.

- [ ] **Step 3: Implement.** Interface:

```dart
import 'dart:typed_data';

/// Uploading user photos. Phase 3a uses it for place photos; Phase 3b will
/// reuse it for review photos.
abstract interface class PhotoStorageRepository {
  /// Uploads [bytes] under [fileName] (must be `<uid>/<uuid>.jpg`) and
  /// returns the public URL.
  Future<String> uploadPhoto(Uint8List bytes, {required String fileName});

  Future<void> deletePhoto(String url);
}
```

Sample:

```dart
import 'dart:typed_data';

import '../../domain/repositories/photo_storage_repository.dart';

/// In-memory stand-in; returns fake URLs and records uploads for tests.
class SamplePhotoStorageRepository implements PhotoStorageRepository {
  final Map<String, Uint8List> uploads = {};

  @override
  Future<String> uploadPhoto(Uint8List bytes, {required String fileName}) async {
    uploads[fileName] = bytes;
    return 'https://photos.example/$fileName';
  }

  @override
  Future<void> deletePhoto(String url) async {
    uploads.removeWhere((name, _) => url.endsWith(name));
  }
}
```

Supabase (bucket `place-photos`):

```dart
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/photo_storage_repository.dart';

/// Photos in the public Supabase Storage bucket `place-photos`.
class SupabasePhotoStorageRepository implements PhotoStorageRepository {
  SupabasePhotoStorageRepository(this._client);

  final SupabaseClient _client;

  static const _bucket = 'place-photos';

  @override
  Future<String> uploadPhoto(Uint8List bytes, {required String fileName}) async {
    await _client.storage.from(_bucket).uploadBinary(
        fileName, bytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'));
    return _client.storage.from(_bucket).getPublicUrl(fileName);
  }

  @override
  Future<void> deletePhoto(String url) async {
    final marker = '/$_bucket/';
    final index = url.indexOf(marker);
    if (index == -1) return;
    await _client.storage
        .from(_bucket)
        .remove([url.substring(index + marker.length)]);
  }
}
```

Provider (in `repository_providers.dart`, imports to match):

```dart
final photoStorageRepositoryProvider = Provider<PhotoStorageRepository>(
    (ref) => SupabasePhotoStorageRepository(Supabase.instance.client));
```

- [ ] **Step 4: Run** suite + analyze — pass/clean.
- [ ] **Step 5: Commit** — `git commit -m "Add PhotoStorageRepository with Supabase Storage backend"`.

---

### Task 5: `AddPlaceController`

**Files:**
- Create: `app/lib/application/add_place_controller.dart`
- Test: `app/test/ceylon_review_test.dart`

**Interfaces:**
- Consumes: `placesRepositoryProvider.addPlace` (Task 3), `photoStorageRepositoryProvider` (Task 4), `authProvider`, `allPlacesProvider` / `trendingPlacesProvider` / `placesByCategoryProvider` / `filteredPlacesProvider` / `placeSearchProvider` (existing).
- Produces: `addPlaceControllerProvider` — `AsyncNotifierProvider<AddPlaceController, void>` with `Future<Place> submit({required String name, required PlaceCategory category, required String district, required String description, required double latitude, required double longitude, int? priceLevel, String? opensAt, String? closesAt, Uint8List? photoBytes})`.

- [ ] **Step 1: Write the failing test** (reuse the test file's existing `_FakeAuthNotifier`; container pattern mirrors the `myFavoriteIdsProvider` tests):

```dart
group('AddPlaceController', () {
  test('submit uploads photo, stores place, returns it', () async {
    final placesRepo = SamplePlacesRepository(places: []);
    final photoRepo = SamplePhotoStorageRepository();
    final container = ProviderContainer(overrides: [
      placesRepositoryProvider.overrideWithValue(placesRepo),
      photoStorageRepositoryProvider.overrideWithValue(photoRepo),
      authProvider.overrideWith(_FakeAuthNotifier.new),
    ]);
    addTearDown(container.dispose);

    final place = await container
        .read(addPlaceControllerProvider.notifier)
        .submit(
          name: 'Hidden Waterfall',
          category: PlaceCategory.nature,
          district: 'Badulla',
          description: 'A quiet spot.',
          latitude: 6.87,
          longitude: 81.05,
          photoBytes: Uint8List.fromList([9, 9]),
        );

    expect(place.name, 'Hidden Waterfall');
    expect(place.addedBy, isNotNull);
    expect(place.imageUrl, startsWith('https://photos.example/'));
    expect((await placesRepo.fetchAll()).single.id, place.id);
    expect(photoRepo.uploads, hasLength(1));
  });

  test('submit without photo uses empty imageUrl and stores place', () async {
    final placesRepo = SamplePlacesRepository(places: []);
    final container = ProviderContainer(overrides: [
      placesRepositoryProvider.overrideWithValue(placesRepo),
      photoStorageRepositoryProvider
          .overrideWithValue(SamplePhotoStorageRepository()),
      authProvider.overrideWith(_FakeAuthNotifier.new),
    ]);
    addTearDown(container.dispose);

    final place = await container
        .read(addPlaceControllerProvider.notifier)
        .submit(
          name: 'No Photo Cafe',
          category: PlaceCategory.food,
          district: 'Colombo',
          description: '',
          latitude: 6.9,
          longitude: 79.8,
        );
    expect(place.imageUrl, '');
  });
});
```

- [ ] **Step 2: Run** — FAIL (`addPlaceControllerProvider` undefined).

- [ ] **Step 3: Implement** `add_place_controller.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/category.dart';
import '../domain/models/place.dart';
import 'auth_provider.dart';
import 'places_provider.dart';
import 'repository_providers.dart';

/// Submits a new community place: uploads the photo (if any), inserts the
/// place, and refreshes place lists so it appears everywhere immediately.
class AddPlaceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Place> submit({
    required String name,
    required PlaceCategory category,
    required String district,
    required String description,
    required double latitude,
    required double longitude,
    int? priceLevel,
    String? opensAt,
    String? closesAt,
    Uint8List? photoBytes,
  }) async {
    state = const AsyncLoading();
    try {
      final user = ref.read(authProvider);
      if (user == null) {
        throw StateError('You must be signed in to add a place.');
      }
      final id = const Uuid().v4();
      var imageUrl = '';
      if (photoBytes != null) {
        imageUrl = await ref
            .read(photoStorageRepositoryProvider)
            .uploadPhoto(photoBytes, fileName: '${user.id}/$id.jpg');
      }
      final created = await ref.read(placesRepositoryProvider).addPlace(Place(
            id: id,
            name: name,
            category: category,
            district: district,
            latitude: latitude,
            longitude: longitude,
            rating: 0,
            reviewCount: 0,
            description: description,
            imageUrl: imageUrl,
            priceLevel: priceLevel,
            opensAt: opensAt,
            closesAt: closesAt,
            addedBy: user.id,
          ));
      ref.invalidate(allPlacesProvider);
      ref.invalidate(trendingPlacesProvider);
      ref.invalidate(placesByCategoryProvider);
      ref.invalidate(placeSearchProvider);
      state = const AsyncData(null);
      return created;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final addPlaceControllerProvider =
    AsyncNotifierProvider<AddPlaceController, void>(AddPlaceController.new);
```

Note: `filteredPlacesProvider` derives from `placesByCategoryProvider`, so invalidating the latter refreshes it. `AppUser.id` exists as of Task 2.

Add `uuid: ^4.5.1` to `app/pubspec.yaml` dependencies and run `flutter pub get`.

- [ ] **Step 4: Run** suite + analyze — pass/clean.
- [ ] **Step 5: Commit** — `git commit -m "Add AddPlaceController for community place submission"` (include pubspec.yaml + pubspec.lock).

---

### Task 6: `AddPlaceScreen` UI

**Files:**
- Create: `app/lib/presentation/screens/add_place/add_place_screen.dart`
- Modify: `app/pubspec.yaml` (add `image_picker: ^1.1.2`)
- Modify: `app/ios/Runner/Info.plist` (camera/photo permission strings)
- Test: `app/test/ceylon_review_test.dart` (validation-focused widget test)

**Interfaces:**
- Consumes: `addPlaceControllerProvider.submit` (Task 5 — exact signature above), `locationProvider` (existing, `AsyncNotifierProvider<LocationNotifier, Position?>` with `refresh()`), `categoryHasPricing()` from `../../widgets/filters_bottom_sheet.dart`, `PlaceDetailScreen(placeId:)`.
- Produces: `AddPlaceScreen({String? initialName})` — pushed by Task 7's entry points.

- [ ] **Step 1: Add dependencies/config.** `image_picker: ^1.1.2` in pubspec; `flutter pub get`. In `Info.plist` (inside the main `<dict>`):

```xml
	<key>NSCameraUsageDescription</key>
	<string>Take a photo of the place you are adding.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>Choose a photo of the place you are adding.</string>
```

(Android needs no manifest change: `image_picker` uses the system photo picker / camera intent.)

- [ ] **Step 2: Build the screen.** Full file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../application/add_place_controller.dart';
import '../../../application/location_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/category.dart';
import '../../widgets/filters_bottom_sheet.dart' show categoryHasPricing;
import '../place_detail/place_detail_screen.dart';

/// Form for adding a community place: details, optional photo
/// (camera/gallery), and a map-pinned location.
class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key, this.initialName});

  /// Prefill for the name field (from the search empty state).
  final String? initialName;

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  static const _islandCenter = LatLng(7.5, 80.7);

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();

  PlaceCategory? _category;
  int? _priceLevel;
  TimeOfDay? _opensAt;
  TimeOfDay? _closesAt;
  XFile? _photo;
  LatLng? _pin;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _hhmm(TimeOfDay? t) => t == null
      ? null
      : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _useCurrentLocation() async {
    await ref.read(locationProvider.notifier).refresh();
    final position = ref.read(locationProvider).valueOrNull;
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enable location to use your position.')));
      }
      return;
    }
    setState(() => _pin = LatLng(position.latitude, position.longitude));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _pin == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_category == null
              ? 'Pick a category.'
              : 'Drop a pin for the location.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final place = await ref.read(addPlaceControllerProvider.notifier).submit(
            name: _nameController.text.trim(),
            category: _category!,
            district: _districtController.text.trim(),
            description: _descriptionController.text.trim(),
            latitude: _pin!.latitude,
            longitude: _pin!.longitude,
            priceLevel: categoryHasPricing(_category!) ? _priceLevel : null,
            opensAt: _hhmm(_opensAt),
            closesAt: _hhmm(_closesAt),
            photoBytes: _photo == null ? null : await _photo!.readAsBytes(),
          );
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => PlaceDetailScreen(placeId: place.id)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not add the place. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final c in PlaceCategory.selectable)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'District is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 3,
            ),
            if (_category != null && categoryHasPricing(_category!)) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Price level', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (var level = 1; level <= 3; level++)
                    ChoiceChip(
                      label: Text('₨' * level),
                      selected: _priceLevel == level,
                      onSelected: (_) => setState(() =>
                          _priceLevel = _priceLevel == level ? null : level),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Opening hours (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context,
                          initialTime:
                              _opensAt ?? const TimeOfDay(hour: 9, minute: 0));
                      if (t != null) setState(() => _opensAt = t);
                    },
                    child: Text(_opensAt == null
                        ? 'Opens at'
                        : 'Opens ${_hhmm(_opensAt)}'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context,
                          initialTime: _closesAt ??
                              const TimeOfDay(hour: 18, minute: 0));
                      if (t != null) setState(() => _closesAt = t);
                    },
                    child: Text(_closesAt == null
                        ? 'Closes at'
                        : 'Closes ${_hhmm(_closesAt)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Photo (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Camera'),
                  onPressed: () => _pickPhoto(ImageSource.camera),
                ),
                const SizedBox(width: AppSpacing.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                ),
                if (_photo != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Location — tap the map or use your position',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _pin ?? _islandCenter,
                    initialZoom: _pin == null ? 7.3 : 13,
                    onTap: (_, point) => setState(() => _pin = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ceylonreview.ceylon_review',
                    ),
                    if (_pin != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _pin!,
                          width: 44,
                          height: 44,
                          child: Icon(Icons.location_pin,
                              size: 40, color: theme.colorScheme.primary),
                        ),
                      ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Use my current location'),
              onPressed: _useCurrentLocation,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Place'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Widget test** (validation only — do NOT assert on the map, whose tiles don't load in tests; the `errorBuilder`-less TileLayer failures are non-fatal). Add to the `Widgets` group:

```dart
testWidgets('AddPlaceScreen blocks save when required fields missing',
    (tester) async {
  await tester.pumpWidget(themed(
    const AddPlaceScreen(),
    overrides: [
      authProvider.overrideWith(_FakeAuthNotifier.new),
    ],
  ));
  await tester.pump();
  await tester.ensureVisible(find.text('Add Place'));
  await tester.tap(find.text('Add Place'));
  await tester.pump();
  expect(find.text('Name is required'), findsOneWidget);
  expect(find.text('District is required'), findsOneWidget);
});
```

If `themed()` wraps in `MaterialApp` without a `Scaffold` ancestor issue, this works as-is; run and adjust padding/scroll only if the button is off-screen (`ensureVisible` handles it).

- [ ] **Step 4: Run** suite + analyze — pass/clean.
- [ ] **Step 5: Commit** — `git commit -m "Add AddPlaceScreen with map pin and photo picker"` (screen, test, pubspec files, Info.plist).

---

### Task 7: Entry points + Community badge

**Files:**
- Modify: `app/lib/presentation/screens/home/home_screen.dart` (`_SearchResults` empty state, ~line 225-238)
- Modify: `app/lib/presentation/screens/map/map_screen.dart` (FAB)
- Modify: `app/lib/presentation/widgets/place_card.dart` (badge)
- Modify: `app/lib/presentation/screens/place_detail/place_detail_screen.dart` (badge)

**Interfaces:**
- Consumes: `AddPlaceScreen({String? initialName})` (Task 6), `authProvider`, `Place.addedBy` (Task 2).

- [ ] **Step 1: Search empty state.** In `_SearchResults.build`'s empty branch (after the existing "No places found" `Text`), add — and gate on sign-in by reading `final user = ref.watch(authProvider);` at the top of `build`:

```dart
                if (user != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_location_alt_rounded),
                    label: const Text("Can't find it? Add this place"),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddPlaceScreen(initialName: query),
                      ),
                    ),
                  ),
                ],
```

Add imports for `auth_provider.dart` and `add_place_screen.dart`.

- [ ] **Step 2: Map FAB.** In `MapScreen.build`, read `final user = ref.watch(authProvider);` and add to the `Scaffold`:

```dart
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              tooltip: 'Add a place',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPlaceScreen()),
              ),
              child: const Icon(Icons.add_location_alt_rounded),
            ),
```

Add the two imports.

- [ ] **Step 3: Community badge.** In `place_card.dart`, next to the category label `Positioned` (bottom-left), extend the existing `Text` to a `Row` when community-added:

```dart
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.sm,
                    child: Row(
                      children: [
                        Text(
                          place.category.label,
                          style: AppTypography.overline(Colors.white),
                        ),
                        if (place.addedBy != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('COMMUNITY',
                                style: AppTypography.overline(Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
```

In `place_detail_screen.dart`, in the hero overlay `Column` (the one with the category label + name, lines ~87-99), change the category `Text` line to:

```dart
                        Row(
                          children: [
                            Text(place.category.label,
                                style: AppTypography.overline(Colors.white)),
                            if (place.addedBy != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text('· COMMUNITY',
                                  style: AppTypography.overline(Colors.white70)),
                            ],
                          ],
                        ),
```

- [ ] **Step 4: Run** suite + analyze — pass/clean (existing PlaceCard test unaffected: sample places have null `addedBy`).
- [ ] **Step 5: Commit** — `git commit -m "Add place entry points and Community badge"`.

---

### Task 8: End-to-end verification and README update

**Files:**
- Modify: `README.md`, `app/README.md`

- [ ] **Step 1:** `cd app && flutter test` — all pass — and `flutter analyze` — clean.
- [ ] **Step 2: Manual on-device** (`flutter run` on the connected Android tablet `R83X201SG1Z`): signed in → Map tab shows the + FAB → add a place with gallery photo + map pin → lands on its detail screen with COMMUNITY badge → write a review on it → search finds it; search for a nonsense string shows the "Add this place" button prefilled. Sign out → FAB and search button hidden.
- [ ] **Step 3: Cross-check via MCP** `execute_sql`: `select id, name, added_by, image_url from public.places where added_by is not null;` shows the new row with a `place-photos` public URL; `select name from storage.objects where bucket_id = 'place-photos';` shows the uploaded object under `<uid>/`. `get_advisors` (security): no new warnings.
- [ ] **Step 4: READMEs.** `app/README.md` Features (after the Favorites bullet):

```markdown
- **Add a Place** — signed-in users add missing places with full details, a camera/gallery photo, and a map-pinned location (or their current position); community places are public instantly and badged "COMMUNITY"
```

Root `README.md` Features (after the Favorites bullet):

```markdown
- Add a Place: users add missing places with a photo and map-pinned location; community places are instantly public and reviewable
```

Also add `image_picker` and `uuid` to `app/README.md`'s Tech Stack table (row: `Photos & ids | image_picker, uuid`).

- [ ] **Step 5: Commit** — `git commit -m "Document Add a Place feature in READMEs"`.
