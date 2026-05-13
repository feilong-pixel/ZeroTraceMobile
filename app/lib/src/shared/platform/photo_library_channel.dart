import 'dart:typed_data';

import 'photo_asset.dart';
import 'photo_library.dart';
import 'photo_permission.dart';

class PhotoLibraryChannel implements PhotoLibrary {
  const PhotoLibraryChannel();

  @override
  Future<PhotoPermissionStatus> requestPermission() {
    throw UnimplementedError(
        'Native photo permission bridge is not wired yet.');
  }

  @override
  Stream<PhotoAsset> enumerateAssets() {
    throw UnimplementedError(
        'Native photo enumeration bridge is not wired yet.');
  }

  @override
  Future<Uint8List> loadThumbnail(String assetId, ThumbnailSpec spec) {
    throw UnimplementedError('Native thumbnail bridge is not wired yet.');
  }

  @override
  Future<Uint8List> openOriginalBytes(String assetId) {
    throw UnimplementedError('Native original-byte bridge is not wired yet.');
  }

  @override
  Future<DeletionResult> requestDelete(List<String> assetIds) {
    throw UnimplementedError('Native deletion bridge is not wired yet.');
  }
}
