import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'sync_models.dart';

class PhoneSyncClient {
  PhoneSyncClient({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<Map<String, Object?>> pair({
    required PairingPayload payload,
    required String deviceId,
    required String deviceName,
    String deviceType = 'android',
    String platform = 'android',
  }) {
    return _postJson(
      Uri.parse(payload.pairUrl ?? '${payload.baseUrl}/api/mobile/pair'),
      {
        'pairing_token': payload.pairingToken,
        'device_type': deviceType,
        'device_id': deviceId,
        'device_name': deviceName,
        'device_model': deviceName,
        'platform': platform,
        'app_id': 'zerotrace-mobile',
        'app_version': '0.1.1',
        'owner_label': deviceName,
        'capabilities': {
          'asset_id': true,
          'raw_upload': true,
          'sha256_on_device': false,
        },
      },
    );
  }

  Future<Map<String, Object?>> startSync(SyncTarget target) {
    return _postJson(
      Uri.parse('${target.baseUrl}/api/mobile/sync/start'),
      {
        'device_type': target.deviceType,
        'device_id': target.deviceId,
        'sync_token': target.syncToken,
        'last_client_cursor': target.lastClientCursor ?? '',
        'battery_state': 'unknown',
        'network_type': 'wifi',
      },
    );
  }

  Future<Map<String, Object?>> sendManifest({
    required SyncTarget target,
    required String sessionId,
    required List<SyncManifestItem> items,
  }) {
    return _postJson(
      Uri.parse('${target.baseUrl}/api/mobile/sync/manifest'),
      {
        'session_id': sessionId,
        'server_id': target.serverId,
        'root_id': target.rootId,
        'device_type': target.deviceType,
        'device_id': target.deviceId,
        'items': items.map((item) => item.toJson()).toList(),
      },
    );
  }

  Future<Map<String, Object?>> uploadBytes({
    required SyncTarget target,
    required String sessionId,
    required SyncManifestItem item,
    required Uint8List bytes,
    String? uploadBatchId,
  }) async {
    final uri = Uri.parse('${target.baseUrl}/api/mobile/sync/upload');
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.binary;
    request.headers.add(
      'X-ZTB-Mobile-Metadata',
      jsonEncode({
        'session_id': sessionId,
        'upload_batch_id': uploadBatchId,
        'device_type': target.deviceType,
        'device_id': target.deviceId,
        'item_id': item.itemId,
        'server_id': target.serverId,
        'root_id': target.rootId,
        'filename': item.filename,
        'created_at': item.createdAt?.toIso8601String(),
        'modified_at': item.modifiedAt?.toIso8601String(),
        'size': item.size,
        'mime_type': item.mimeType,
      }),
    );
    request.add(bytes);
    final response = await request.close();
    return _decodeResponse(response);
  }

  Future<Map<String, Object?>> _postJson(
    Uri uri,
    Map<String, Object?> body,
  ) async {
    final request = await _httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    return _decodeResponse(response);
  }

  Future<Map<String, Object?>> _decodeResponse(
    HttpClientResponse response,
  ) async {
    final raw = await response.transform(utf8.decoder).join();
    final decoded = raw.isEmpty ? <String, Object?>{} : jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Server response must be a JSON object.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        _errorMessage(decoded, response.statusCode),
        uri: response.redirects.isEmpty
            ? null
            : response.redirects.last.location,
      );
    }
    return decoded;
  }

  String _errorMessage(Map<String, Object?> decoded, int statusCode) {
    final detail = decoded['detail'];
    if (detail is String && detail.isNotEmpty) {
      return detail;
    }
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    final error = decoded['error'];
    if (error is String && error.isNotEmpty) {
      return error;
    }
    return 'Sync request failed with HTTP $statusCode.';
  }
}
