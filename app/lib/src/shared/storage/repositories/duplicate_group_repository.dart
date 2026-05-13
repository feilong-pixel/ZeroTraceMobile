import '../app_database.dart';
import '../models/duplicate_group_record.dart';

class DuplicateGroupRepository {
  DuplicateGroupRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<void> replaceForScanRun(
    String scanRunId,
    List<DuplicateGroupRecord> groups,
  ) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      final existingGroups = await txn.query(
        'duplicate_groups',
        columns: ['id'],
        where: 'scan_run_id = ?',
        whereArgs: [scanRunId],
      );
      final existingGroupIds =
          existingGroups.map((row) => row['id']! as String).toList();

      for (final groupId in existingGroupIds) {
        await txn.delete(
          'duplicate_group_members',
          where: 'group_id = ?',
          whereArgs: [groupId],
        );
      }
      await txn.delete(
        'duplicate_groups',
        where: 'scan_run_id = ?',
        whereArgs: [scanRunId],
      );

      final batch = txn.batch();
      for (final group in groups) {
        batch.insert('duplicate_groups', group.toMap());
        for (final member in group.members) {
          batch.insert('duplicate_group_members', member.toMap());
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<DuplicateGroupRecord>> listLatest() async {
    final db = await _database.database;
    final scanRuns = await db.query(
      'scan_runs',
      columns: ['id'],
      orderBy: 'started_at DESC',
      limit: 1,
    );
    if (scanRuns.isEmpty) {
      return const [];
    }

    return listByScanRun(scanRuns.single['id']! as String);
  }

  Future<List<DuplicateGroupRecord>> listByScanRun(String scanRunId) async {
    final db = await _database.database;
    final groupRows = await db.query(
      'duplicate_groups',
      where: 'scan_run_id = ?',
      whereArgs: [scanRunId],
      orderBy: 'created_at DESC',
    );

    final groups = <DuplicateGroupRecord>[];
    for (final groupRow in groupRows) {
      final groupId = groupRow['id']! as String;
      final memberRows = await db.rawQuery(
        '''
        SELECT
          duplicate_group_members.group_id,
          duplicate_group_members.asset_id,
          duplicate_group_members.selected_for_cleanup,
          duplicate_group_members.keep_recommended,
          scan_assets.path_hint
        FROM duplicate_group_members
        LEFT JOIN scan_assets
          ON scan_assets.asset_id = duplicate_group_members.asset_id
        WHERE duplicate_group_members.group_id = ?
        ORDER BY
          duplicate_group_members.keep_recommended DESC,
          duplicate_group_members.asset_id ASC
        ''',
        [groupId],
      );
      groups.add(
        DuplicateGroupRecord.fromMap(
          groupRow,
          memberRows.map(DuplicateGroupMemberRecord.fromMap).toList(),
        ),
      );
    }

    return groups;
  }
}
