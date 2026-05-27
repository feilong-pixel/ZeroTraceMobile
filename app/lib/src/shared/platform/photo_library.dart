import 'dart:typed_data';

import 'photo_asset.dart';
import 'photo_permission.dart';

abstract interface class PhotoLibrary {
  Future<PhotoPermissionStatus> requestPermission();

  Stream<PhotoAsset> enumerateAssets();

  Future<Uint8List> openOriginalBytes(String assetId);
}
