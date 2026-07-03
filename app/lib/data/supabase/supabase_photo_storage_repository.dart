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
