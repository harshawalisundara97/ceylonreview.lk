import 'dart:typed_data';

import '../../domain/repositories/photo_storage_repository.dart';

/// In-memory stand-in; returns fake URLs and records uploads for tests.
class SamplePhotoStorageRepository implements PhotoStorageRepository {
  final Map<String, Uint8List> uploads = {};

  @override
  Future<String> uploadPhoto(Uint8List bytes, {required String fileName}) async {
    uploads[fileName] = bytes;
    return 'https://photos.example/$fileName';
  }

  @override
  Future<void> deletePhoto(String url) async {
    uploads.removeWhere((name, _) => url.endsWith(name));
  }
}
