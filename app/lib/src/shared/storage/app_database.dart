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
    await db.execute('''
      CREATE TABLE ${DatabaseSchema.scanRuns} (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        status TEXT NOT NULL,
        source TEXT NOT NULL,
        asset_count INTEGER NOT NULL DEFAULT 0,
        exact_group_count INTEGER NOT NULL DEFAULT 0,
        similar_group_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.scanAssets} (
        asset_id TEXT PRIMARY KEY,
        latest_scan_run_id TEXT NOT NULL,
        path_hint TEXT,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        size_bytes INTEGER NOT NULL,
        created_at TEXT,
        modified_at TEXT,
        media_type TEXT NOT NULL,
        fingerprint TEXT NOT NULL,
        scanned_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_scan_assets_latest_scan_run_id
      ON ${DatabaseSchema.scanAssets} (latest_scan_run_id)
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.scanHashes} (
        asset_id TEXT PRIMARY KEY,
        content_hash TEXT,
        perceptual_hash TEXT,
        perceptual_hash_algorithm TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.duplicateGroups} (
        id TEXT PRIMARY KEY,
        scan_run_id TEXT NOT NULL,
        confidence TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.duplicateGroupMembers} (
        group_id TEXT NOT NULL,
        asset_id TEXT NOT NULL,
        selected_for_cleanup INTEGER NOT NULL DEFAULT 0,
        keep_recommended INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (group_id, asset_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseSchema.auditRecords} (
        id TEXT PRIMARY KEY,
        operation_type TEXT NOT NULL,
        requested_at TEXT NOT NULL,
        platform_result TEXT NOT NULL,
        requested_asset_count INTEGER NOT NULL DEFAULT 0,
        completed_asset_count INTEGER NOT NULL DEFAULT 0,
        failed_asset_count INTEGER NOT NULL DEFAULT 0,
        message TEXT
      )
    ''');
  }

  static Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 1 is the initial schema. Future migrations stay explicit here.
  }
}
