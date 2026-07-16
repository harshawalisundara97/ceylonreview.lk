import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/review.dart';
import '../../domain/repositories/reviews_repository.dart';

/// Reviews backed by the Supabase `reviews` table. A database trigger keeps
/// `places.rating` / `review_count` in sync on every insert.
class SupabaseReviewsRepository implements ReviewsRepository {
  SupabaseReviewsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Review>> fetchForPlace(String placeId) async {
    final rows = await _client
        .from('reviews')
        .select()
        .eq('place_id', placeId)
        .order('created_at', ascending: false);
    return rows.map(_reviewFromRow).toList();
  }

  @override
  Future<List<Review>> fetchMine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('reviews')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return rows.map(_reviewFromRow).toList();
  }

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
}

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
