import '../app_database.dart';
import '../models/scan_run_record.dart';

class ScanRunRepository {
  ScanRunRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsert(ScanRunRecord scanRun) async {
    final db = await _database.database;
    await db.rawInsert(_upsertScanRunSql, _scanRunArgs(scanRun));
  }

  Future<ScanRunRecord?> findById(String id) async {
    final db = await _database.database;
    final rows = await db.query(
      'scan_runs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanRunRecord.fromMap(rows.single);
  }

  Future<ScanRunRecord?> latest() async {
    final db = await _database.database;
    final rows = await db.query(
      'scan_runs',
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return ScanRunRecord.fromMap(rows.single);
  }

  static const _upsertScanRunSql = '''
    INSERT INTO scan_runs (
      id,
      started_at,
      completed_at,
      status,
      source,
      asset_count,
      exact_group_count,
      similar_group_count
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
      started_at = excluded.started_at,
      completed_at = excluded.completed_at,
      status = excluded.status,
      source = excluded.source,
      asset_count = excluded.asset_count,
      exact_group_count = excluded.exact_group_count,
      similar_group_count = excluded.similar_group_count
  ''';

  static List<Object?> _scanRunArgs(ScanRunRecord scanRun) {
    final map = scanRun.toMap();
    return [
      map['id'],
      map['started_at'],
      map['completed_at'],
      map['status'],
      map['source'],
      map['asset_count'],
      map['exact_group_count'],
      map['similar_group_count'],
    ];
  }
}
