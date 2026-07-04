import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ceylon_review/application/add_place_controller.dart';
import 'package:ceylon_review/application/auth_provider.dart';
import 'package:ceylon_review/application/favorites_provider.dart';
import 'package:ceylon_review/application/repository_providers.dart';
import 'package:ceylon_review/core/theme/app_theme.dart';
import 'package:ceylon_review/data/sample/sample_favorites_repository.dart';
import 'package:ceylon_review/data/sample/sample_photo_storage_repository.dart';
import 'package:ceylon_review/data/sample/sample_places_repository.dart';
import 'package:ceylon_review/data/sample/sample_reviews_repository.dart';
import 'package:ceylon_review/domain/models/category.dart';
import 'package:ceylon_review/domain/models/place.dart';
import 'package:ceylon_review/domain/models/user.dart';
import 'package:ceylon_review/domain/repositories/favorites_repository.dart';
import 'package:ceylon_review/domain/repositories/places_repository.dart';
import 'package:ceylon_review/presentation/screens/add_place/add_place_screen.dart';
import 'package:ceylon_review/presentation/widgets/place_card.dart';
import 'package:ceylon_review/presentation/widgets/rating_stars.dart';
import 'package:ceylon_review/presentation/widgets/star_picker.dart';

void main() {
  group('SamplePlacesRepository', () {
    final repo = SamplePlacesRepository();

    test('fetchByCategory returns only that category', () async {
      final beaches = await repo.fetchByCategory(PlaceCategory.beach);
      expect(beaches, isNotEmpty);
      expect(beaches.every((p) => p.category == PlaceCategory.beach), isTrue);
    });

    test('fetchByCategory(home) returns everything', () async {
      final all = await repo.fetchAll();
      final home = await repo.fetchByCategory(PlaceCategory.home);
      expect(home.length, all.length);
    });

    test('search matches name and district, case-insensitive', () async {
      expect(await repo.search('mirissa'), isNotEmpty);
      expect(await repo.search('COLOMBO'), isNotEmpty);
      expect(await repo.search('zzz-nowhere'), isEmpty);
    });

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
  });

  group('SampleReviewsRepository', () {
    test('added review appears for its place, newest first', () async {
      final repo = SampleReviewsRepository();
      await repo.add(
        placeId: 'odel',
        authorName: 'Test User',
        rating: 5,
        text: 'Wonderful shopping experience.',
      );
      final reviews = await repo.fetchForPlace('odel');
      expect(reviews.first.authorName, 'Test User');
      expect(await repo.fetchMine(), hasLength(1));
    });
  });

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

  group('myFavoriteIdsProvider', () {
    ProviderContainer buildContainer(FavoritesRepository repo, AppUser? user) {
      return ProviderContainer(overrides: [
        favoritesRepositoryProvider.overrideWithValue(repo),
        authProvider.overrideWith(() => _FakeAuthNotifier(user)),
      ]);
    }

    test('signed-out user has no favorites', () async {
      final container = buildContainer(SampleFavoritesRepository(), null);
      addTearDown(container.dispose);

      final ids = await container.read(myFavoriteIdsProvider.future);
      expect(ids, isEmpty);
    });

    test('toggle adds then removes a place id, backed by the repository',
        () async {
      final repo = SampleFavoritesRepository();
      final container = buildContainer(
          repo, const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'));
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

  group('Place formatting', () {
    test('rating shows one decimal and counts abbreviate to k', () async {
      final places = await SamplePlacesRepository().fetchAll();
      final crab = places.firstWhere((p) => p.id == 'ministry-of-crab');
      expect(crab.ratingLabel, '4.8');
      expect(crab.reviewCountLabel, '2.3k');
    });
  });

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

  group('AddPlaceController', () {
    test('submit uploads photo, stores place, returns it', () async {
      final placesRepo = SamplePlacesRepository(places: []);
      final photoRepo = SamplePhotoStorageRepository();
      final container = ProviderContainer(overrides: [
        placesRepositoryProvider.overrideWithValue(placesRepo),
        photoStorageRepositoryProvider.overrideWithValue(photoRepo),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
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

    test('submit without photo uses empty imageUrl and stores place',
        () async {
      final placesRepo = SamplePlacesRepository(places: []);
      final container = ProviderContainer(overrides: [
        placesRepositoryProvider.overrideWithValue(placesRepo),
        photoStorageRepositoryProvider
            .overrideWithValue(SamplePhotoStorageRepository()),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
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

    test('submit deletes the uploaded photo if the place insert fails',
        () async {
      final photoRepo = SamplePhotoStorageRepository();
      final container = ProviderContainer(overrides: [
        placesRepositoryProvider.overrideWithValue(_ThrowingPlacesRepository()),
        photoStorageRepositoryProvider.overrideWithValue(photoRepo),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
      ]);
      addTearDown(container.dispose);

      await expectLater(
        container.read(addPlaceControllerProvider.notifier).submit(
              name: 'Doomed Place',
              category: PlaceCategory.nature,
              district: 'Badulla',
              description: '',
              latitude: 6.87,
              longitude: 81.05,
              photoBytes: Uint8List.fromList([9, 9]),
            ),
        throwsA(isA<StateError>()),
      );
      expect(photoRepo.uploads, isEmpty);
    });
  });

  group('Widgets', () {
    Widget themed(Widget child, {List<Override> overrides = const []}) =>
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.of(PlaceCategory.home, Brightness.light),
            home: Scaffold(body: Center(child: child)),
          ),
        );

    testWidgets('RatingStars renders five stars with half support',
        (tester) async {
      await tester.pumpWidget(themed(const RatingStars(rating: 3.5)));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });

    testWidgets('StarPicker reports tapped star', (tester) async {
      int? picked;
      await tester.pumpWidget(themed(StatefulBuilder(
        builder: (context, setState) => StarPicker(
          value: picked ?? 0,
          onChanged: (v) => setState(() => picked = v),
        ),
      )));
      await tester.tap(find.byType(IconButton).at(3));
      await tester.pump();
      expect(picked, 4);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    });

    testWidgets('PlaceCard heart toggles favorite state', (tester) async {
      final repo = SampleFavoritesRepository();
      final place = (await SamplePlacesRepository().fetchAll())
          .firstWhere((p) => p.id == 'odel');

      await tester.pumpWidget(themed(
        PlaceCard(place: place, onTap: () {}),
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(repo),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'user-1', name: 'Test User', email: 't@example.com'))),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(await repo.fetchMyFavoriteIds(), {'odel'});
    });

    testWidgets('AddPlaceScreen blocks save when required fields missing',
        (tester) async {
      // The form is taller than the default test surface, which leaves the
      // submit button outside the ListView's lazy-build cache extent.
      // Enlarge the surface so every field builds without needing to scroll.
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
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('District is required'), findsOneWidget);
    });
  });
}

class _ThrowingPlacesRepository implements PlacesRepository {
  @override
  Future<Place> addPlace(Place place) async {
    throw StateError('insert failed');
  }

  @override
  Future<List<Place>> fetchAll() async => [];

  @override
  Future<Place?> fetchById(String id) async => null;

  @override
  Future<List<Place>> fetchByCategory(PlaceCategory category) async => [];

  @override
  Future<List<Place>> fetchTrending() async => [];

  @override
  Future<List<Place>> search(String query) async => [];
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AppUser? _user;

  @override
  AppUser? build() => _user;
}
