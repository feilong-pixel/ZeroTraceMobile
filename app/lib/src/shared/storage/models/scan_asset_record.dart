class ScanAssetRecord {
  const ScanAssetRecord({
    required this.assetId,
    required this.latestScanRunId,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.mediaType,
    required this.fingerprint,
    required this.scannedAt,
    this.pathHint,
    this.createdAt,
    this.modifiedAt,
  });

  final String assetId;
  final String latestScanRunId;
  final String? pathHint;
  final int width;
  final int height;
  final int sizeBytes;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String mediaType;
  final String fingerprint;
  final DateTime scannedAt;

  Map<String, Object?> toMap() {
    return {
      'asset_id': assetId,
      'latest_scan_run_id': latestScanRunId,
      'path_hint': pathHint,
      'width': width,
      'height': height,
      'size_bytes': sizeBytes,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'modified_at': modifiedAt?.toUtc().toIso8601String(),
      'media_type': mediaType,
      'fingerprint': fingerprint,
      'scanned_at': scannedAt.toUtc().toIso8601String(),
    };
  }

  static ScanAssetRecord fromMap(Map<String, Object?> map) {
    return ScanAssetRecord(
      assetId: map['asset_id']! as String,
      latestScanRunId: map['latest_scan_run_id']! as String,
      pathHint: map['path_hint'] as String?,
      width: map['width']! as int,
      height: map['height']! as int,
      sizeBytes: map['size_bytes']! as int,
      createdAt: _parseDate(map['created_at']),
      modifiedAt: _parseDate(map['modified_at']),
      mediaType: map['media_type']! as String,
      fingerprint: map['fingerprint']! as String,
      scannedAt: DateTime.parse(map['scanned_at']! as String),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String);
  }
}
