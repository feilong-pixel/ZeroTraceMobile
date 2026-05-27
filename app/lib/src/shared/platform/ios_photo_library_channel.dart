import 'dart:typed_data';

import 'photo_asset.dart';
import 'photo_library.dart';
import 'photo_permission.dart';

class IosPhotoLibraryChannel implements PhotoLibrary {
  const IosPhotoLibraryChannel();

  @override
  Future<PhotoPermissionStatus> requestPermission() {
    throw UnimplementedError('iPhone photo bridge is reserved for later.');
  }

  @override
  Stream<PhotoAsset> enumerateAssets() {
    throw UnimplementedError('iPhone photo bridge is reserved for later.');
  }

  @override
  Future<Uint8List> openOriginalBytes(String assetId) {
    throw UnimplementedError('iPhone photo bridge is reserved for later.');
  }
}
