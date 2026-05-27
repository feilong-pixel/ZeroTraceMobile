import 'package:sqflite/sqflite.dart';

import '../app_database.dart';
import '../schema.dart';
import '../../sync/sync_models.dart';

class SyncRepository {
  SyncRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> upsertTarget(SyncTarget target) async {
    final db = await _database.database;
    await db.insert(
      DatabaseSchema.syncTargets,
      target.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SyncTarget?> latestTarget() async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseSchema.syncTargets,
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return SyncTarget.fromMap(rows.single);
  }

  Future<void> upsertItemState(SyncItemState itemState) async {
    final db = await _database.database;
    await db.insert(
      DatabaseSchema.syncItems,
      itemState.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Set<String>> terminalItemIds(SyncTarget target) async {
    final db = await _database.database;
    final rows = await db.query(
      DatabaseSchema.syncItems,
      columns: ['item_id'],
      where:
          'server_id = ? AND root_id = ? AND device_id = ? AND status IN (?, ?, ?, ?, ?)',
      whereArgs: [
        target.serverId,
        target.rootId,
        target.deviceId,
        'imported',
        'already_imported',
        'skipped_duplicate',
        'skipped_deleted_locally',
        'uploaded',
      ],
    );
    return rows.map((row) => row['item_id']! as String).toSet();
  }
}
