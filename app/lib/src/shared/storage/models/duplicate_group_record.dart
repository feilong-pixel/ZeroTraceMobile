class DuplicateGroupRecord {
  const DuplicateGroupRecord({
    required this.id,
    required this.scanRunId,
    required this.confidence,
    required this.createdAt,
    required this.members,
  });

  final String id;
  final String scanRunId;
  final String confidence;
  final DateTime createdAt;
  final List<DuplicateGroupMemberRecord> members;

  int get selectedCount {
    return members.where((member) => member.selectedForCleanup).length;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'scan_run_id': scanRunId,
      'confidence': confidence,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  static DuplicateGroupRecord fromMap(
    Map<String, Object?> map,
    List<DuplicateGroupMemberRecord> members,
  ) {
    return DuplicateGroupRecord(
      id: map['id']! as String,
      scanRunId: map['scan_run_id']! as String,
      confidence: map['confidence']! as String,
      createdAt: DateTime.parse(map['created_at']! as String),
      members: members,
    );
  }
}

class DuplicateGroupMemberRecord {
  const DuplicateGroupMemberRecord({
    required this.groupId,
    required this.assetId,
    required this.selectedForCleanup,
    required this.keepRecommended,
    this.pathHint,
  });

  final String groupId;
  final String assetId;
  final bool selectedForCleanup;
  final bool keepRecommended;
  final String? pathHint;

  Map<String, Object?> toMap() {
    return {
      'group_id': groupId,
      'asset_id': assetId,
      'selected_for_cleanup': selectedForCleanup ? 1 : 0,
      'keep_recommended': keepRecommended ? 1 : 0,
    };
  }

  static DuplicateGroupMemberRecord fromMap(Map<String, Object?> map) {
    return DuplicateGroupMemberRecord(
      groupId: map['group_id']! as String,
      assetId: map['asset_id']! as String,
      selectedForCleanup: map['selected_for_cleanup'] == 1,
      keepRecommended: map['keep_recommended'] == 1,
      pathHint: map['path_hint'] as String?,
    );
  }
}
