import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample/sample_auth_repository.dart';
import '../data/sample/sample_places_repository.dart';
import '../data/sample/sample_reviews_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/places_repository.dart';
import '../domain/repositories/reviews_repository.dart';

/// Dependency injection seam: swapping to a real backend later means
/// overriding these three providers and nothing else.
final placesRepositoryProvider =
    Provider<PlacesRepository>((ref) => SamplePlacesRepository());

final reviewsRepositoryProvider =
    Provider<ReviewsRepository>((ref) => SampleReviewsRepository());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => SampleAuthRepository());
