import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/category.dart';
import '../domain/models/place.dart';
import 'repository_providers.dart';

final allPlacesProvider = FutureProvider<List<Place>>(
    (ref) => ref.watch(placesRepositoryProvider).fetchAll());

final trendingPlacesProvider = FutureProvider<List<Place>>(
    (ref) => ref.watch(placesRepositoryProvider).fetchTrending());

final placesByCategoryProvider =
    FutureProvider.family<List<Place>, PlaceCategory>((ref, category) =>
        ref.watch(placesRepositoryProvider).fetchByCategory(category));

final placeByIdProvider = FutureProvider.family<Place?, String>(
    (ref, id) => ref.watch(placesRepositoryProvider).fetchById(id));

final placeSearchProvider = FutureProvider.family<List<Place>, String>(
    (ref, query) => ref.watch(placesRepositoryProvider).search(query));
