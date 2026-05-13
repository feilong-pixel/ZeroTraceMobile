import '../app_database.dart';
import '../models/scan_asset_record.dart';
import '../models/scan_hash_record.dart';

class ScanAssetRepository {
  ScanAssetRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsertAsset(ScanAssetRecord asset) async {
    final db = await _database.database;
    await db.rawInsert(_upsertAssetSql, _assetArgs(asset));
  }

  Future<void> upsertAssets(List<ScanAssetRecord> assets) async {
    if (assets.isEmpty) {
      return;
    }

    final db = await _database.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final asset in assets) {
        batch.rawInsert(_upsertAssetSql, _assetArgs(asset));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> upsertHash(ScanHashRecord hash) async {
    final db = await _database.database;
    await db.rawInsert(_upsertHashSql, _hashArgs(hash));
  }

  Future<ScanAssetRecord?> findByAssetId(String assetId) async {
    final db = await _database.database;
    final rows = await db.query(
      'scan_assets',
      where: 'asset_id = ?',
      whereArgs: [assetId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanAssetRecord.fromMap(rows.single);
  }

  Future<List<ScanAssetRecord>> listByScanRun(String scanRunId) async {
    final db = await _database.database;
    final rows = await db.query(
      'scan_assets',
      where: 'latest_scan_run_id = ?',
      whereArgs: [scanRunId],
      orderBy: 'scanned_at DESC',
    );
    return rows.map(ScanAssetRecord.fromMap).toList();
  }

  Future<ScanHashRecord?> findHash(String assetId) async {
    final db = await _database.database;
    final rows = await db.query(
      'scan_hashes',
      where: 'asset_id = ?',
      whereArgs: [assetId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanHashRecord.fromMap(rows.single);
  }

  static const _upsertAssetSql = '''
    INSERT INTO scan_assets (
      asset_id,
      latest_scan_run_id,
      path_hint,
      width,
      height,
      size_bytes,
      created_at,
      modified_at,
      media_type,
      fingerprint,
      scanned_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(asset_id) DO UPDATE SET
      latest_scan_run_id = excluded.latest_scan_run_id,
      path_hint = excluded.path_hint,
      width = excluded.width,
      height = excluded.height,
      size_bytes = excluded.size_bytes,
      created_at = excluded.created_at,
      modified_at = excluded.modified_at,
      media_type = excluded.media_type,
      fingerprint = excluded.fingerprint,
      scanned_at = excluded.scanned_at
  ''';

  static const _upsertHashSql = '''
    INSERT INTO scan_hashes (
      asset_id,
      content_hash,
      perceptual_hash,
      perceptual_hash_algorithm,
      updated_at
    ) VALUES (?, ?, ?, ?, ?)
    ON CONFLICT(asset_id) DO UPDATE SET
      content_hash = excluded.content_hash,
      perceptual_hash = excluded.perceptual_hash,
      perceptual_hash_algorithm = excluded.perceptual_hash_algorithm,
      updated_at = excluded.updated_at
  ''';

  static List<Object?> _assetArgs(ScanAssetRecord asset) {
    final map = asset.toMap();
    return [
      map['asset_id'],
      map['latest_scan_run_id'],
      map['path_hint'],
      map['width'],
      map['height'],
      map['size_bytes'],
      map['created_at'],
      map['modified_at'],
      map['media_type'],
      map['fingerprint'],
      map['scanned_at'],
    ];
  }

  static List<Object?> _hashArgs(ScanHashRecord hash) {
    final map = hash.toMap();
    return [
      map['asset_id'],
      map['content_hash'],
      map['perceptual_hash'],
      map['perceptual_hash_algorithm'],
      map['updated_at'],
    ];
  }
}
