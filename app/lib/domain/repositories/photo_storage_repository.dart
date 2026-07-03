import 'dart:typed_data';

/// Uploading user photos. Phase 3a uses it for place photos; Phase 3b will
/// reuse it for review photos.
abstract interface class PhotoStorageRepository {
  /// Uploads [bytes] under [fileName] (must be `<uid>/<uuid>.jpg`) and
  /// returns the public URL.
  Future<String> uploadPhoto(Uint8List bytes, {required String fileName});

  Future<void> deletePhoto(String url);
}
