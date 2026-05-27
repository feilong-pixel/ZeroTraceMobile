import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'schema.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, 'zerotrace_mobile.sqlite');
    final opened = await openDatabase(
      databasePath,
      version: DatabaseSchema.version,
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );

    _database = opened;
    return opened;
  }

  Future<void> close() async {
    final existing = _database;
    if (existing == null) {
      return;
    }

    await existing.close();
    _database = null;
  }

  static Future<void> _createSchema(Database db, int version) async {
    await _createSyncSchema(db);
  }

  static Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createSyncSchema(db);
    }
    if (oldVersion < 3) {
      return;
    }
  }

  static Future<void> _createSyncSchema(Database db) async {
    await db.execute('''
      CREATE TABLE ${DatabaseSchema.syncTargets} (
        id TEXT PRIMARY KEY,
        server_id TEXT NOT NULL,
        root_id TEXT NOT NULL,
        base_url TEXT NOT NULL,
        pairing_token TEXT NOT NULL,
        sync_token TEXT,
        sync_token_expires_at TEXT,
        destination_root TEXT,
        device_id TEXT NOT NULL,
        device_type TEXT NOT NULL,
        device_name TEXT NOT NULL,
        batch_size INTEGER NOT NULL DEFAULT 10,
        last_client_cursor TEXT,
        last_synced_at TEXT,
        paired_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_sync_targets_identity
      ON ${DatabaseSchema.syncTargets} (server_id, root_id, device_id)
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.syncItems} (
        server_id TEXT NOT NULL,
        root_id TEXT NOT NULL,
        device_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        status TEXT NOT NULL,
        sha256 TEXT,
        local_path TEXT,
        existing_local_path TEXT,
        error TEXT,
        synced_at TEXT NOT NULL,
        PRIMARY KEY (server_id, root_id, device_id, item_id)
      )
    ''');
  }
}
