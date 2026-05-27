import 'dart:convert';

class PairingPayload {
  const PairingPayload({
    required this.serverId,
    required this.rootId,
    required this.baseUrl,
    required this.pairingToken,
    this.pairUrl,
    this.syncStartUrl,
    this.manifestUrl,
    this.uploadUrl,
    this.statusUrl,
  });

  final String serverId;
  final String rootId;
  final String baseUrl;
  final String pairingToken;
  final String? pairUrl;
  final String? syncStartUrl;
  final String? manifestUrl;
  final String? uploadUrl;
  final String? statusUrl;

  static PairingPayload parse(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Pairing payload must be a JSON object.');
    }
    if (decoded['protocol'] != 'zerotrace-phone-sync') {
      throw const FormatException('Unsupported pairing protocol.');
    }
    if (decoded['version'] != 1) {
      throw const FormatException('Unsupported pairing version.');
    }

    return PairingPayload(
      serverId: _requiredString(decoded, 'server_id'),
      rootId: _requiredString(decoded, 'root_id'),
      baseUrl: _requiredString(decoded, 'base_url'),
      pairingToken: _requiredString(decoded, 'pairing_token'),
      pairUrl: decoded['pair_url'] as String?,
      syncStartUrl: decoded['sync_start_url'] as String?,
      manifestUrl: decoded['manifest_url'] as String?,
      uploadUrl: decoded['upload_url'] as String?,
      statusUrl: decoded['status_url'] as String?,
    );
  }
}

class SyncTarget {
  const SyncTarget({
    required this.serverId,
    required this.rootId,
    required this.baseUrl,
    required this.pairingToken,
    required this.deviceId,
    required this.deviceType,
    required this.deviceName,
    required this.pairedAt,
    required this.updatedAt,
    this.syncToken,
    this.syncTokenExpiresAt,
    this.destinationRoot,
    this.batchSize = 10,
    this.lastClientCursor,
    this.lastSyncedAt,
  });

  final String serverId;
  final String rootId;
  final String baseUrl;
  final String pairingToken;
  final String deviceId;
  final String deviceType;
  final String deviceName;
  final DateTime pairedAt;
  final DateTime updatedAt;
  final String? syncToken;
  final DateTime? syncTokenExpiresAt;
  final String? destinationRoot;
  final int batchSize;
  final String? lastClientCursor;
  final DateTime? lastSyncedAt;

  String get id => '$serverId::$rootId::$deviceId';

  SyncTarget copyWith({
    String? syncToken,
    DateTime? syncTokenExpiresAt,
    String? destinationRoot,
    int? batchSize,
    String? lastClientCursor,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  }) {
    return SyncTarget(
      serverId: serverId,
      rootId: rootId,
      baseUrl: baseUrl,
      pairingToken: pairingToken,
      deviceId: deviceId,
      deviceType: deviceType,
      deviceName: deviceName,
      pairedAt: pairedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncToken: syncToken ?? this.syncToken,
      syncTokenExpiresAt: syncTokenExpiresAt ?? this.syncTokenExpiresAt,
      destinationRoot: destinationRoot ?? this.destinationRoot,
      batchSize: batchSize ?? this.batchSize,
      lastClientCursor: lastClientCursor ?? this.lastClientCursor,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'root_id': rootId,
      'base_url': baseUrl,
      'pairing_token': pairingToken,
      'sync_token': syncToken,
      'sync_token_expires_at': syncTokenExpiresAt?.toIso8601String(),
      'destination_root': destinationRoot,
      'device_id': deviceId,
      'device_type': deviceType,
      'device_name': deviceName,
      'batch_size': batchSize,
      'last_client_cursor': lastClientCursor,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'paired_at': pairedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static SyncTarget fromMap(Map<String, Object?> map) {
    return SyncTarget(
      serverId: map['server_id']! as String,
      rootId: map['root_id']! as String,
      baseUrl: map['base_url']! as String,
      pairingToken: map['pairing_token']! as String,
      syncToken: map['sync_token'] as String?,
      syncTokenExpiresAt: _optionalDate(map['sync_token_expires_at']),
      destinationRoot: map['destination_root'] as String?,
      deviceId: map['device_id']! as String,
      deviceType: map['device_type']! as String,
      deviceName: map['device_name']! as String,
      batchSize: map['batch_size']! as int,
      lastClientCursor: map['last_client_cursor'] as String?,
      lastSyncedAt: _optionalDate(map['last_synced_at']),
      pairedAt: DateTime.parse(map['paired_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }
}

class SyncItemState {
  const SyncItemState({
    required this.serverId,
    required this.rootId,
    required this.deviceId,
    required this.itemId,
    required this.status,
    required this.syncedAt,
    this.sha256,
    this.localPath,
    this.existingLocalPath,
    this.error,
  });

  final String serverId;
  final String rootId;
  final String deviceId;
  final String itemId;
  final String status;
  final DateTime syncedAt;
  final String? sha256;
  final String? localPath;
  final String? existingLocalPath;
  final String? error;

  Map<String, Object?> toMap() {
    return {
      'server_id': serverId,
      'root_id': rootId,
      'device_id': deviceId,
      'item_id': itemId,
      'status': status,
      'sha256': sha256,
      'local_path': localPath,
      'existing_local_path': existingLocalPath,
      'error': error,
      'synced_at': syncedAt.toIso8601String(),
    };
  }
}

class SyncManifestItem {
  const SyncManifestItem({
    required this.itemId,
    required this.filename,
    required this.mediaType,
    required this.mimeType,
    required this.size,
    this.createdAt,
    this.modifiedAt,
    this.timezone,
    this.album,
    this.width,
    this.height,
    this.durationMs = 0,
  });

  final String itemId;
  final String filename;
  final String mediaType;
  final String mimeType;
  final int size;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final String? timezone;
  final String? album;
  final int? width;
  final int? height;
  final int durationMs;

  Map<String, Object?> toJson() {
    return {
      'item_id': itemId,
      'filename': filename,
      'media_type': mediaType,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt?.toIso8601String(),
      'modified_at': modifiedAt?.toIso8601String(),
      'timezone': timezone,
      'album': album,
      'width': width,
      'height': height,
      'duration_ms': durationMs,
    };
  }
}

String _requiredString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Missing required pairing field: $key.');
}

DateTime? _optionalDate(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.parse(value);
}
