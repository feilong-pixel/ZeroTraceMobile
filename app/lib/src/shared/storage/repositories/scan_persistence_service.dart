import '../models/scan_asset_record.dart';
import '../models/scan_hash_record.dart';
import '../models/scan_run_record.dart';
import 'scan_asset_repository.dart';
import 'scan_run_repository.dart';

class ScanPersistenceService {
  ScanPersistenceService({
    ScanRunRepository? scanRuns,
    ScanAssetRepository? scanAssets,
  })  : _scanRuns = scanRuns ?? ScanRunRepository(),
        _scanAssets = scanAssets ?? ScanAssetRepository();

  final ScanRunRepository _scanRuns;
  final ScanAssetRepository _scanAssets;

  Future<void> saveScanSnapshot({
    required ScanRunRecord scanRun,
    required List<ScanAssetRecord> assets,
    List<ScanHashRecord> hashes = const [],
  }) async {
    await _scanRuns.upsert(scanRun);
    await _scanAssets.upsertAssets(assets);

    for (final hash in hashes) {
      await _scanAssets.upsertHash(hash);
    }
  }
}
