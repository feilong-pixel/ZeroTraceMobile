enum PhotoMediaType {
  image,
}

class PhotoAsset {
  const PhotoAsset({
    required this.id,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.mediaType,
    this.displayName,
    this.createdAt,
  });

  final String id;
  final String? displayName;
  final int width;
  final int height;
  final int sizeBytes;
  final DateTime? createdAt;
  final PhotoMediaType mediaType;
}
