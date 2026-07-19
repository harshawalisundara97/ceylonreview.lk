import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ceylon_review/core/l10n_ext.dart';
import 'package:ceylon_review/application/add_place_controller.dart';
import 'package:ceylon_review/application/auth_provider.dart';
import 'package:ceylon_review/application/favorites_provider.dart';
import 'package:ceylon_review/application/leaderboard_provider.dart';
import 'package:ceylon_review/application/locale_provider.dart';
import 'package:ceylon_review/application/repository_providers.dart';
import 'package:ceylon_review/application/reviews_provider.dart';
import 'package:ceylon_review/core/sri_lanka_districts.dart';
import 'package:ceylon_review/core/theme/app_theme.dart';
import 'package:ceylon_review/data/sample/sample_favorites_repository.dart';
import 'package:ceylon_review/data/sample/sample_leaderboard_repository.dart';
import 'package:ceylon_review/data/sample/sample_photo_storage_repository.dart';
import 'package:ceylon_review/data/sample/sample_places_repository.dart';
import 'package:ceylon_review/data/sample/sample_reviews_repository.dart';
import 'package:ceylon_review/domain/models/category.dart';
import 'package:ceylon_review/domain/models/leaderboard_entry.dart';
import 'package:ceylon_review/domain/models/place.dart';
import 'package:ceylon_review/domain/models/review.dart';
import 'package:ceylon_review/domain/models/user.dart';
import 'package:ceylon_review/domain/repositories/favorites_repository.dart';
import 'package:ceylon_review/domain/repositories/geocoding_repository.dart';
import 'package:ceylon_review/domain/repositories/places_repository.dart';
import 'package:ceylon_review/domain/repositories/leaderboard_repository.dart';
import 'package:ceylon_review/domain/repositories/reviews_repository.dart';
import 'package:ceylon_review/presentation/screens/add_place/add_place_screen.dart';
import 'package:ceylon_review/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:ceylon_review/presentation/screens/place_detail/place_detail_screen.dart';
import 'package:ceylon_review/presentation/screens/write_review/write_review_screen.dart';
import 'package:ceylon_review/presentation/widgets/photo_viewer.dart';
import 'package:ceylon_review/presentation/widgets/place_card.dart';
import 'package:ceylon_review/presentation/widgets/rating_stars.dart';
import 'package:ceylon_review/presentation/widgets/review_tile.dart';
import 'package:ceylon_review/presentation/widgets/star_picker.dart';
import 'package:latlong2/latlong.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    // Mock image URLs, pass through others
    if (_isImageUrl(url)) {
      return _MockHttpRequest();
    }
    return _realHttpClient.getUrl(url);
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return _realHttpClient.postUrl(url);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    // Mock image URLs, pass through others
    if (_isImageUrl(url)) {
      return _MockHttpRequest();
    }
    return _realHttpClient.openUrl(method, url);
  }

  bool _isImageUrl(Uri url) {
    return url.scheme == 'https' && url.host.contains('photos.example');
  }

  @override
  void close({bool force = false}) {
    _realHttpClient.close(force: force);
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpResponse();
  }

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) {
    return null;
  }
}

class _MockHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _pngData.length;

  @override
  bool get persistentConnection => false;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_pngData).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  // Minimal 1x1 transparent PNG
  static const List<int> _pngData = [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
    0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0, 144, 119, 83,
    222, 0, 0, 0, 12, 73, 68, 65, 84, 8, 223, 99, 248, 15, 0, 0,
    1, 1, 1, 0, 24, 221, 184, 84, 0, 0, 0, 0, 73, 69, 78, 68,
    174, 66, 96, 130
  ];

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

late HttpClient _realHttpClient;

void main() {
  setUpAll(() {
    // Save the original HttpClient before setting overrides to avoid infinite recursion
    _realHttpClient = HttpClient();
    // Use custom HttpClient to mock network image loading in tests
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('sriLankaDistricts', () {
    test('contains all 25 districts with no duplicates', () {
      expect(sriLankaDistricts.length, 25);
      expect(sriLankaDistricts.toSet().length, 25);
      expect(sriLankaDistricts, contains('Colombo'));
      expect(sriLankaDistricts, contains('Jaffna'));
    });
  });

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

  group('SampleLeaderboardRepository', () {
    test('fetchLeaderboard returns entries ordered by points descending',
        () async {
      final repo = SampleLeaderboardRepository();
      final list = await repo.fetchLeaderboard();
      expect(list, isNotEmpty);
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].points, greaterThanOrEqualTo(list[i].points));
      }
      expect(list.first.rank, 1);
    });

    test('fetchMyRank finds the matching entry by userId', () async {
      final repo = SampleLeaderboardRepository();
      final list = await repo.fetchLeaderboard();
      final target = list[1];
      final mine = await repo.fetchMyRank(target.userId);
      expect(mine?.rank, target.rank);
    });

    test('fetchMyRank returns null for an unknown user', () async {
      final repo = SampleLeaderboardRepository();
      final mine = await repo.fetchMyRank('nobody');
      expect(mine, isNull);
    });
  });

  group('Leaderboard providers', () {
    test('leaderboardProvider returns the repository\'s ranked list',
        () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
      ]);
      addTearDown(container.dispose);

      final list = await container.read(leaderboardProvider.future);
      expect(list.first.name, 'Harsha W.');
    });

    test('myRankProvider is null when signed out', () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
        authProvider.overrideWith(() => _FakeAuthNotifier(null)),
      ]);
      addTearDown(container.dispose);

      final mine = await container.read(myRankProvider.future);
      expect(mine, isNull);
    });

    test('myRankProvider resolves the signed-in user\'s entry', () async {
      final container = ProviderContainer(overrides: [
        leaderboardRepositoryProvider
            .overrideWithValue(SampleLeaderboardRepository()),
        authProvider.overrideWith(() => _FakeAuthNotifier(
            const AppUser(id: 'u-dilan', name: 'Dilan', email: 'd@example.com'))),
      ]);
      addTearDown(container.dispose);

      final mine = await container.read(myRankProvider.future);
      expect(mine?.rank, 3);
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

  group('LeaderboardEntry', () {
    test('carries rank, points, and an optional rank change', () {
      const withChange = LeaderboardEntry(
        userId: 'u1',
        name: 'Nadeesha',
        points: 860,
        rank: 2,
        rankChange: 3,
      );
      const withoutChange = LeaderboardEntry(
        userId: 'u2',
        name: 'New User',
        points: 10,
        rank: 40,
      );
      expect(withChange.rankChange, 3);
      expect(withoutChange.rankChange, isNull);
    });
  });

  group('Widgets', () {
    Widget themed(Widget child, {List<Override> overrides = const []}) =>
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            theme: AppTheme.of(PlaceCategory.home, Brightness.light),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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

    testWidgets('PlaceCard with open-hours chip fits the trending carousel',
        (tester) async {
      // Same constraints as the Trending This Week carousel on Home:
      // fixed 220-wide cards inside a fixed-height horizontal strip. The
      // place has hours set so the _OpenNowChip row renders.
      final place = Place(
        id: 'test',
        name: 'Test Place',
        category: PlaceCategory.food,
        district: 'Colombo',
        latitude: 6.9,
        longitude: 79.8,
        rating: 4.5,
        reviewCount: 1200,
        description: 'Test',
        imageUrl: 'https://example.com/x.jpg',
        opensAt: '00:00',
        closesAt: '23:59',
      );

      await tester.pumpWidget(themed(
        SizedBox(
          height: 256,
          child: PlaceCard(place: place, width: 220, onTap: () {}),
        ),
        overrides: [
          favoritesRepositoryProvider
              .overrideWithValue(SampleFavoritesRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pump();

      // A RenderFlex overflow surfaces as an exception during layout.
      expect(tester.takeException(), isNull);
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

    testWidgets('LeaderboardScreen shows a podium for the top 3',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(SampleLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      // The crown above the #1 podium slot bobs forever
      // (`..repeat(reverse: true)`), so `pumpAndSettle` never settles here.
      // Pump a fixed amount of time instead, enough for the entrance
      // animations and the delayed podium reveals to finish.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Harsha W.'), findsOneWidget);
      expect(find.text('Nadeesha'), findsOneWidget);
      expect(find.text('Dilan'), findsOneWidget);
      // Rank 4+ render in the list below the podium.
      expect(find.text('Sanduni P.'), findsOneWidget);
    });

    testWidgets('LeaderboardScreen shows an empty state with no reviews yet',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(_EmptyLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(null)),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Be the first to post a review and claim #1!'),
          findsOneWidget);
    });

    testWidgets('LeaderboardScreen shows a your-rank card outside the top 3',
        (tester) async {
      await tester.pumpWidget(themed(
        const LeaderboardScreen(),
        overrides: [
          leaderboardRepositoryProvider
              .overrideWithValue(SampleLeaderboardRepository()),
          authProvider.overrideWith(() => _FakeAuthNotifier(
              const AppUser(id: 'u-kasun', name: 'Kasun R.', email: 'k@example.com'))),
        ],
      ));
      // Same bobbing-crown caveat as above: pump a fixed duration instead of
      // pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('#5'), findsOneWidget);
    });

    testWidgets(
        'WriteReviewScreen shows an Add photos section and posts a review '
        'without photos', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
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
  });

  group('Localization', () {
    testWidgets('resolves Sinhala and Tamil strings', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('si'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => Text(context.l10n.language)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('භාෂාව'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ta'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => Text(context.l10n.language)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('மொழி'), findsOneWidget);
    });
  });

  group('localeProvider', () {
    test('defaults to null and restores persisted locale', () async {
      SharedPreferences.setMockInitialValues({});
      var container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(localeProvider), isNull);

      await container.read(localeProvider.notifier).setLocale(const Locale('si'));
      expect(container.read(localeProvider), const Locale('si'));

      // A fresh container simulates an app restart reading the same prefs.
      container = ProviderContainer();
      addTearDown(container.dispose);
      // Allow the async restore to complete.
      container.read(localeProvider);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(localeProvider), const Locale('si'));
    });

    test('setLocale(null) clears persistence', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ta'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(localeProvider.notifier).setLocale(null);
      expect(container.read(localeProvider), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
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

class _EmptyLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async => [];

  @override
  Future<LeaderboardEntry?> fetchMyRank(String userId) async => null;
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AppUser? _user;

  @override
  AppUser? build() => _user;
}

class _FakeGeocodingRepository implements GeocodingRepository {
  @override
  Future<LatLng?> search(String query) async {
    if (query == 'Ella') return const LatLng(6.8667, 81.0466);
    return null;
  }
}
