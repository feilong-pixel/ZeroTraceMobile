class ScanHashRecord {
  const ScanHashRecord({
    required this.assetId,
    required this.updatedAt,
    this.contentHash,
    this.perceptualHash,
    this.perceptualHashAlgorithm,
  });

  final String assetId;
  final String? contentHash;
  final String? perceptualHash;
  final String? perceptualHashAlgorithm;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return {
      'asset_id': assetId,
      'content_hash': contentHash,
      'perceptual_hash': perceptualHash,
      'perceptual_hash_algorithm': perceptualHashAlgorithm,
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  static ScanHashRecord fromMap(Map<String, Object?> map) {
    return ScanHashRecord(
      assetId: map['asset_id']! as String,
      contentHash: map['content_hash'] as String?,
      perceptualHash: map['perceptual_hash'] as String?,
      perceptualHashAlgorithm: map['perceptual_hash_algorithm'] as String?,
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }
}
