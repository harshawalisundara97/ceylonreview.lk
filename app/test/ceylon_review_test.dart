import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this._user);
  final AppUser? _user;

  @override
  AppUser? build() => _user;
}
