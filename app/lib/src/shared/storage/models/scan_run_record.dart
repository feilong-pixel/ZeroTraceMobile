enum ScanRunStatus {
  running,
  completed,
  failed,
  cancelled;

  static ScanRunStatus fromStorage(String value) {
    return ScanRunStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ScanRunStatus.failed,
    );
  }
}

class ScanRunRecord {
  const ScanRunRecord({
    required this.id,
    required this.startedAt,
    required this.status,
    required this.source,
    required this.assetCount,
    required this.exactGroupCount,
    required this.similarGroupCount,
    this.completedAt,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final ScanRunStatus status;
  final String source;
  final int assetCount;
  final int exactGroupCount;
  final int similarGroupCount;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'started_at': startedAt.toUtc().toIso8601String(),
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'status': status.name,
      'source': source,
      'asset_count': assetCount,
      'exact_group_count': exactGroupCount,
      'similar_group_count': similarGroupCount,
    };
  }

  static ScanRunRecord fromMap(Map<String, Object?> map) {
    return ScanRunRecord(
      id: map['id']! as String,
      startedAt: DateTime.parse(map['started_at']! as String),
      completedAt: _parseDate(map['completed_at']),
      status: ScanRunStatus.fromStorage(map['status']! as String),
      source: map['source']! as String,
      assetCount: map['asset_count']! as int,
      exactGroupCount: map['exact_group_count']! as int,
      similarGroupCount: map['similar_group_count']! as int,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.parse(value as String);
  }
}
