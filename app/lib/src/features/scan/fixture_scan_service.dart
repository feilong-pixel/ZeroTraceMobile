import '../../shared/storage/storage.dart';

class FixtureScanService {
  FixtureScanService({
    ScanPersistenceService? scanPersistence,
    DuplicateGroupRepository? duplicateGroups,
  })  : _scanPersistence = scanPersistence ?? ScanPersistenceService(),
        _duplicateGroups = duplicateGroups ?? DuplicateGroupRepository();

  final ScanPersistenceService _scanPersistence;
  final DuplicateGroupRepository _duplicateGroups;

  Future<FixtureScanResult> run() async {
    final now = DateTime.now().toUtc();
    final scanRunId = 'fixture-${now.microsecondsSinceEpoch}';

    final scanRun = ScanRunRecord(
      id: scanRunId,
      startedAt: now,
      completedAt: now,
      status: ScanRunStatus.completed,
      source: 'fixture',
      assetCount: 3,
      exactGroupCount: 1,
      similarGroupCount: 0,
    );

    final assets = [
      ScanAssetRecord(
        assetId: 'fixture-asset-keep',
        latestScanRunId: scanRunId,
        pathHint: 'fixtures/basic_exact/keep.jpg',
        width: 4032,
        height: 3024,
        sizeBytes: 2480000,
        mediaType: 'image',
        fingerprint: 'fixture-exact-a',
        scannedAt: now,
      ),
      ScanAssetRecord(
        assetId: 'fixture-asset-delete',
        latestScanRunId: scanRunId,
        pathHint: 'fixtures/basic_exact/duplicate.jpg',
        width: 4032,
        height: 3024,
        sizeBytes: 2480000,
        mediaType: 'image',
        fingerprint: 'fixture-exact-a',
        scannedAt: now,
      ),
      ScanAssetRecord(
        assetId: 'fixture-asset-unique',
        latestScanRunId: scanRunId,
        pathHint: 'fixtures/basic_exact/unique.jpg',
        width: 1920,
        height: 1080,
        sizeBytes: 980000,
        mediaType: 'image',
        fingerprint: 'fixture-unique',
        scannedAt: now,
      ),
    ];

    final hashes = [
      ScanHashRecord(
        assetId: 'fixture-asset-keep',
        contentHash: 'fixture-content-hash-a',
        perceptualHash: 'fixture-phash-a',
        perceptualHashAlgorithm: 'fixture',
        updatedAt: now,
      ),
      ScanHashRecord(
        assetId: 'fixture-asset-delete',
        contentHash: 'fixture-content-hash-a',
        perceptualHash: 'fixture-phash-a',
        perceptualHashAlgorithm: 'fixture',
        updatedAt: now,
      ),
      ScanHashRecord(
        assetId: 'fixture-asset-unique',
        contentHash: 'fixture-content-hash-unique',
        perceptualHash: 'fixture-phash-unique',
        perceptualHashAlgorithm: 'fixture',
        updatedAt: now,
      ),
    ];

    final groupId = '$scanRunId-exact-a';
    final groups = [
      DuplicateGroupRecord(
        id: groupId,
        scanRunId: scanRunId,
        confidence: 'exact',
        createdAt: now,
        members: [
          DuplicateGroupMemberRecord(
            groupId: groupId,
            assetId: 'fixture-asset-keep',
            selectedForCleanup: false,
            keepRecommended: true,
          ),
          DuplicateGroupMemberRecord(
            groupId: groupId,
            assetId: 'fixture-asset-delete',
            selectedForCleanup: true,
            keepRecommended: false,
          ),
        ],
      ),
    ];

    await _scanPersistence.saveScanSnapshot(
      scanRun: scanRun,
      assets: assets,
      hashes: hashes,
    );
    await _duplicateGroups.replaceForScanRun(scanRunId, groups);

    return const FixtureScanResult(
      assetCount: 3,
      exactGroupCount: 1,
      selectedForCleanupCount: 1,
    );
  }
}

class FixtureScanResult {
  const FixtureScanResult({
    required this.assetCount,
    required this.exactGroupCount,
    required this.selectedForCleanupCount,
  });

  final int assetCount;
  final int exactGroupCount;
  final int selectedForCleanupCount;
}
