import 'dart:typed_data';

import 'photo_asset.dart';
import 'photo_permission.dart';

abstract interface class PhotoLibrary {
  Future<PhotoPermissionStatus> requestPermission();

  Stream<PhotoAsset> enumerateAssets();

  Future<Uint8List> loadThumbnail(
    String assetId,
    ThumbnailSpec spec,
  );

  Future<Uint8List> openOriginalBytes(String assetId);

  Future<DeletionResult> requestDelete(List<String> assetIds);
}

class ThumbnailSpec {
  const ThumbnailSpec({
    required this.width,
    required this.height,
    this.quality = 82,
  });

  final int width;
  final int height;
  final int quality;
}

enum DeletionOutcome {
  accepted,
  cancelled,
  partiallyCompleted,
  failed,
}

class DeletionResult {
  const DeletionResult({
    required this.outcome,
    required this.requestedAssetIds,
    this.deletedAssetIds = const [],
    this.failedAssetIds = const [],
    this.platformMessage,
  });

  final DeletionOutcome outcome;
  final List<String> requestedAssetIds;
  final List<String> deletedAssetIds;
  final List<String> failedAssetIds;
  final String? platformMessage;
}
