class DatabaseSchema {
  const DatabaseSchema._();

  static const version = 1;

  static const scanRuns = 'scan_runs';
  static const scanAssets = 'scan_assets';
  static const scanHashes = 'scan_hashes';
  static const duplicateGroups = 'duplicate_groups';
  static const duplicateGroupMembers = 'duplicate_group_members';
  static const auditRecords = 'audit_records';
}
