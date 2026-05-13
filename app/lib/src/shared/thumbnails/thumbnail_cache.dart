import 'dart:typed_data';

import '../platform/photo_library.dart';

abstract interface class ThumbnailCache {
  Future<Uint8List?> read(String assetId, ThumbnailSpec spec);

  Future<void> write(String assetId, ThumbnailSpec spec, Uint8List bytes);

  Future<void> evict(String assetId);
}

class NoopThumbnailCache implements ThumbnailCache {
  const NoopThumbnailCache();

  @override
  Future<Uint8List?> read(String assetId, ThumbnailSpec spec) async => null;

  @override
  Future<void> write(
      String assetId, ThumbnailSpec spec, Uint8List bytes) async {}

  @override
  Future<void> evict(String assetId) async {}
}
