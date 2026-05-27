import 'package:flutter/services.dart';

import 'photo_asset.dart';
import 'photo_library.dart';
import 'photo_permission.dart';

class AndroidPhotoLibraryChannel implements PhotoLibrary {
  const AndroidPhotoLibraryChannel();

  static const _channel = MethodChannel('zerotrace_mobile/photo_library');

  @override
  Future<PhotoPermissionStatus> requestPermission() async {
    final status = await _channel.invokeMethod<String>('requestPermission');
    return _permissionStatusFromNative(status);
  }

  @override
  Stream<PhotoAsset> enumerateAssets() async* {
    final assets =
        await _channel.invokeListMethod<Map<Object?, Object?>>('listAssets') ??
            const <Map<Object?, Object?>>[];
    for (final asset in assets) {
      yield _assetFromNative(asset);
    }
  }

  @override
  Future<Uint8List> openOriginalBytes(String assetId) async {
    final bytes = await _channel.invokeMethod<Uint8List>(
      'openOriginalBytes',
      {'assetId': assetId},
    );
    if (bytes == null) {
      throw StateError('Native original-byte bridge returned no bytes.');
    }
    return bytes;
  }

  PhotoPermissionStatus _permissionStatusFromNative(String? status) {
    return switch (status) {
      'granted' => PhotoPermissionStatus.granted,
      'limited' => PhotoPermissionStatus.limited,
      'permanentlyDenied' => PhotoPermissionStatus.permanentlyDenied,
      _ => PhotoPermissionStatus.denied,
    };
  }

  PhotoAsset _assetFromNative(Map<Object?, Object?> map) {
    return PhotoAsset(
      id: map['id']! as String,
      displayName: map['displayName'] as String?,
      width: map['width']! as int,
      height: map['height']! as int,
      sizeBytes: map['sizeBytes']! as int,
      createdAt: _dateFromMillis(map['createdAtMillis']),
      mediaType: PhotoMediaType.image,
    );
  }

  DateTime? _dateFromMillis(Object? value) {
    if (value is! int || value <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
}
