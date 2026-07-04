import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase/supabase_auth_repository.dart';
import '../data/supabase/supabase_favorites_repository.dart';
import '../data/supabase/supabase_leaderboard_repository.dart';
import '../data/supabase/supabase_photo_storage_repository.dart';
import '../data/supabase/supabase_places_repository.dart';
import '../data/supabase/supabase_reviews_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/leaderboard_repository.dart';
import '../domain/repositories/photo_storage_repository.dart';
import '../domain/repositories/places_repository.dart';
import '../domain/repositories/reviews_repository.dart';

/// Dependency injection seam: the app runs against Supabase; the sample
/// repositories in `data/sample/` remain available as offline stand-ins by
/// overriding these providers (e.g. in tests).
final placesRepositoryProvider = Provider<PlacesRepository>(
    (ref) => SupabasePlacesRepository(Supabase.instance.client));

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
    (ref) => SupabaseReviewsRepository(Supabase.instance.client));

final authRepositoryProvider = Provider<AuthRepository>(
    (ref) => SupabaseAuthRepository(Supabase.instance.client));

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
    (ref) => SupabaseFavoritesRepository(Supabase.instance.client));

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
    (ref) => SupabaseLeaderboardRepository(Supabase.instance.client));

final photoStorageRepositoryProvider = Provider<PhotoStorageRepository>(
    (ref) => SupabasePhotoStorageRepository(Supabase.instance.client));
