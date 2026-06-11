import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ceylon_review/core/theme/app_theme.dart';
import 'package:ceylon_review/data/sample/sample_places_repository.dart';
import 'package:ceylon_review/data/sample/sample_reviews_repository.dart';
import 'package:ceylon_review/domain/models/category.dart';
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

  group('Place formatting', () {
    test('rating shows one decimal and counts abbreviate to k', () async {
      final places = await SamplePlacesRepository().fetchAll();
      final crab = places.firstWhere((p) => p.id == 'ministry-of-crab');
      expect(crab.ratingLabel, '4.8');
      expect(crab.reviewCountLabel, '2.3k');
    });
  });

  group('Widgets', () {
    Widget themed(Widget child) => MaterialApp(
          theme: AppTheme.of(PlaceCategory.home, Brightness.light),
          home: Scaffold(body: Center(child: child)),
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
  });
}
