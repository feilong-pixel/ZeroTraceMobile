import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../shared/i18n/app_localizations.dart';
import '../../shared/platform/photo_asset.dart';
import '../../shared/platform/photo_library_channel.dart';
import '../../shared/platform/photo_library.dart';
import '../../shared/platform/photo_permission.dart';
import '../../shared/storage/repositories/sync_repository.dart';
import '../../shared/sync/phone_sync_client.dart';
import '../../shared/sync/sync_models.dart';
import 'qr_pairing_scan_screen.dart';

class PhoneSyncScreen extends StatefulWidget {
  const PhoneSyncScreen({
    super.key,
    PhoneSyncClient? syncClient,
    SyncRepository? repository,
    PhotoLibrary? photoLibrary,
  })  : _syncClient = syncClient,
        _repository = repository,
        _photoLibrary = photoLibrary;

  final PhoneSyncClient? _syncClient;
  final SyncRepository? _repository;
  final PhotoLibrary? _photoLibrary;

  @override
  State<PhoneSyncScreen> createState() => _PhoneSyncScreenState();
}

class _PhoneSyncScreenState extends State<PhoneSyncScreen> {
  final _payloadController = TextEditingController();
  late final SyncRepository _repository;
  late final PhoneSyncClient _syncClient;
  late final PhotoLibrary _photoLibrary;
  SyncTarget? _target;
  String? _message;
  bool _isPairing = false;
  bool _isSendingManifest = false;
  bool _isAutoSyncing = false;
  bool _stopAutoSyncRequested = false;
  String? _syncPhase;
  String? _currentUploadName;
  bool _syncComplete = false;
  int _currentUploadIndex = 0;
  int _currentUploadTotal = 0;
  final List<String> _recentFailures = [];
  int _lastManifestCount = 0;
  int _lastUploadCount = 0;
  int _lastSkipCount = 0;
  int _lastFailureCount = 0;
  int _autoBatchCount = 0;
  int _autoManifestCount = 0;
  int _autoUploadCount = 0;
  int _autoSkipCount = 0;
  int _autoFailureCount = 0;

  static const _deviceId = 'zerotrace-mobile-local-device';
  static const _deviceName = 'ExtraSync';
  static const _manifestBatchSize = 10;
  static const _maxRecentFailures = 5;

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? SyncRepository();
    _syncClient = widget._syncClient ?? PhoneSyncClient();
    _photoLibrary = widget._photoLibrary ?? const AndroidPhotoLibraryChannel();
    _loadLatestTarget();
  }

  @override
  void dispose() {
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestTarget() async {
    final target = await _repository.latestTarget();
    if (!mounted) {
      return;
    }
    setState(() {
      _target = target;
    });
  }

  Future<void> _pairWithDesktop() async {
    final l10n = context.l10n;
    setState(() {
      _isPairing = true;
      _message = null;
    });
    try {
      final payload = PairingPayload.parse(_payloadController.text);
      final now = DateTime.now();
      final response = await _syncClient.pair(
        payload: payload,
        deviceId: _deviceId,
        deviceName: _deviceName,
        deviceType: 'android',
        platform: 'android',
      );
      final target = _targetFromPairing(payload, response, now);
      await _repository.upsertTarget(target);
      if (!mounted) {
        return;
      }
      setState(() {
        _target = target;
        _message = l10n.text('sync.pairingSaved');
      });
    } on Object catch (error) {
      setState(() {
        _message = _friendlyError(l10n, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPairing = false;
        });
      }
    }
  }

  Future<void> _scanPairingQr() async {
    if (_isPairing || _syncInProgress) {
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrPairingScanScreen(),
      ),
    );
    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }
    setState(() {
      _payloadController.text = _formatPayloadForDisplay(result);
      _message = context.l10n.text('sync.scanQrFilled');
    });
  }

  Future<void> _sendManifestBatch() async {
    final l10n = context.l10n;
    if (_isAutoSyncing) {
      return;
    }
    setState(() {
      _isSendingManifest = true;
      _syncComplete = false;
      _message = null;
    });
    try {
      final result = await _runManifestBatch(
        pairFirstMessage: l10n.text('sync.pairFirst'),
        permissionDeniedMessage: l10n.text('sync.photoPermissionDenied'),
        l10n: l10n,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _applyLastBatchResult(result);
        _message = _batchMessage(l10n, result);
      });
    } on UnimplementedError {
      setState(() {
        _message = l10n.text('sync.photoBridgeNotReady');
      });
    } on Object catch (error) {
      setState(() {
        _message = _friendlyError(l10n, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingManifest = false;
        });
      }
    }
  }

  Future<void> _startAutoSync() async {
    final l10n = context.l10n;
    if (_isPairing || _isSendingManifest || _isAutoSyncing) {
      return;
    }

    setState(() {
      _isAutoSyncing = true;
      _stopAutoSyncRequested = false;
      _autoBatchCount = 0;
      _autoManifestCount = 0;
      _autoUploadCount = 0;
      _autoSkipCount = 0;
      _autoFailureCount = 0;
      _syncComplete = false;
      _message = l10n.text('sync.autoStarted');
    });

    try {
      while (mounted && !_stopAutoSyncRequested) {
        final result = await _runManifestBatch(
          pairFirstMessage: l10n.text('sync.pairFirst'),
          permissionDeniedMessage: l10n.text('sync.photoPermissionDenied'),
          l10n: l10n,
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _applyLastBatchResult(result);
          if (result.manifestCount > 0) {
            _autoBatchCount += 1;
            _autoManifestCount += result.manifestCount;
            _autoUploadCount += result.uploadedCount;
            _autoSkipCount += result.skipCount;
            _autoFailureCount += result.failureCount;
          }
          _message = _autoMessage(l10n);
        });
        if (result.manifestCount == 0 || result.failureCount > 0) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _message = _stopAutoSyncRequested
            ? '${l10n.text('sync.autoStopped')}\n${_autoMessage(l10n)}'
            : _autoMessage(l10n);
      });
    } on UnimplementedError {
      setState(() {
        _message = l10n.text('sync.photoBridgeNotReady');
      });
    } on Object catch (error) {
      setState(() {
        _message = _friendlyError(l10n, error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAutoSyncing = false;
          _stopAutoSyncRequested = false;
        });
      }
    }
  }

  void _stopAutoSync() {
    setState(() {
      _stopAutoSyncRequested = true;
      _syncPhase = context.l10n.text('sync.phaseStopping');
      _message = context.l10n.text('sync.stopRequested');
    });
  }

  bool get _syncInProgress => _isSendingManifest || _isAutoSyncing;

  Future<bool> _confirmLeaveDuringSync() async {
    if (!_syncInProgress) {
      return true;
    }
    final l10n = context.l10n;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.text('sync.leaveTitle')),
          content: Text(l10n.text('sync.leaveBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.text('sync.leaveStay')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.text('sync.leaveConfirm')),
            ),
          ],
        );
      },
    );
    return shouldLeave ?? false;
  }

  Future<_SyncBatchResult> _runManifestBatch({
    required String pairFirstMessage,
    required String permissionDeniedMessage,
    required AppLocalizations l10n,
  }) async {
    final target = _target;
    if (target == null || target.syncToken == null) {
      throw StateError(pairFirstMessage);
    }
    _setSyncPhase(l10n.text('sync.phasePermission'));
    final permission = await _photoLibrary.requestPermission();
    if (permission != PhotoPermissionStatus.granted &&
        permission != PhotoPermissionStatus.limited) {
      throw StateError(permissionDeniedMessage);
    }

    _setSyncPhase(l10n.text('sync.phaseStarting'));
    final startResponse = await _syncClient.startSync(target);
    final sessionId = startResponse['session_id'] as String?;
    if (sessionId == null || sessionId.isEmpty) {
      throw const FormatException('Missing session_id in sync start response.');
    }

    _setSyncPhase(l10n.text('sync.phaseEnumerating'));
    final terminalIds = await _repository.terminalItemIds(target);
    final items = <SyncManifestItem>[];
    await for (final asset in _photoLibrary.enumerateAssets()) {
      if (terminalIds.contains(asset.id)) {
        continue;
      }
      items.add(_manifestItemFromAsset(asset));
      if (items.length >= _manifestBatchSize) {
        break;
      }
    }

    if (items.isEmpty) {
      _syncComplete = true;
      _setSyncPhase(l10n.text('sync.phaseComplete'));
      return const _SyncBatchResult.empty();
    }

    _setSyncPhase(l10n.text('sync.phaseManifest'));
    final manifestResponse = await _syncClient.sendManifest(
      target: target,
      sessionId: sessionId,
      items: items,
    );
    await _persistSkippedItems(
      target: target,
      manifestResponse: manifestResponse,
    );
    final uploadResult = await _uploadRequestedItems(
      target: target,
      sessionId: sessionId,
      items: items,
      manifestResponse: manifestResponse,
      l10n: l10n,
    );
    final updated = target.copyWith(
      lastSyncedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.upsertTarget(updated);
    _target = updated;
    _setSyncPhase(l10n.text('sync.phaseBatchComplete'));
    return _SyncBatchResult(
      manifestCount: items.length,
      uploadedCount: uploadResult.uploadedCount,
      skipCount: _skippedItemCount(manifestResponse),
      failureCount: uploadResult.failureCount,
    );
  }

  Future<_UploadBatchResult> _uploadRequestedItems({
    required SyncTarget target,
    required String sessionId,
    required List<SyncManifestItem> items,
    required Map<String, Object?> manifestResponse,
    required AppLocalizations l10n,
  }) async {
    final uploadBatchId = manifestResponse['upload_batch_id'] as String?;
    final requestedItemIds = _requestedUploadItemIds(manifestResponse);
    if (requestedItemIds.isEmpty) {
      return const _UploadBatchResult(uploadedCount: 0, failureCount: 0);
    }

    final itemsById = {for (final item in items) item.itemId: item};
    var uploadedCount = 0;
    var failureCount = 0;
    for (var index = 0; index < requestedItemIds.length; index += 1) {
      final itemId = requestedItemIds[index];
      final item = itemsById[itemId];
      if (item == null) {
        continue;
      }
      try {
        _setUploadProgress(
          phase: l10n.text('sync.phaseUploading'),
          name: item.filename,
          index: index + 1,
          total: requestedItemIds.length,
        );
        final bytes = await _photoLibrary.openOriginalBytes(item.itemId);
        final response = await _syncClient.uploadBytes(
          target: target,
          sessionId: sessionId,
          item: item,
          bytes: bytes,
          uploadBatchId: uploadBatchId,
        );
        await _repository.upsertItemState(
          SyncItemState(
            serverId: target.serverId,
            rootId: target.rootId,
            deviceId: target.deviceId,
            itemId: item.itemId,
            status: _terminalStatusFromUpload(response),
            sha256: response['sha256'] as String?,
            localPath: response['local_path'] as String?,
            existingLocalPath: response['existing_local_path'] as String?,
            syncedAt: DateTime.now(),
          ),
        );
        uploadedCount += 1;
      } on Object catch (error) {
        _recordFailure('${item.filename}: ${_friendlyError(l10n, error)}');
        await _repository.upsertItemState(
          SyncItemState(
            serverId: target.serverId,
            rootId: target.rootId,
            deviceId: target.deviceId,
            itemId: item.itemId,
            status: 'failed',
            error: error.toString(),
            syncedAt: DateTime.now(),
          ),
        );
        failureCount += 1;
      }
    }
    return _UploadBatchResult(
      uploadedCount: uploadedCount,
      failureCount: failureCount,
    );
  }

  void _setSyncPhase(String phase) {
    if (!mounted) {
      return;
    }
    setState(() {
      _syncPhase = phase;
      _currentUploadName = null;
      _currentUploadIndex = 0;
      _currentUploadTotal = 0;
    });
  }

  void _setUploadProgress({
    required String phase,
    required String name,
    required int index,
    required int total,
  }) {
    if (!mounted) {
      return;
    }
    setState(() {
      _syncPhase = phase;
      _currentUploadName = name;
      _currentUploadIndex = index;
      _currentUploadTotal = total;
    });
  }

  void _recordFailure(String failure) {
    if (!mounted) {
      return;
    }
    setState(() {
      _recentFailures.insert(0, failure);
      if (_recentFailures.length > _maxRecentFailures) {
        _recentFailures.removeRange(
          _maxRecentFailures,
          _recentFailures.length,
        );
      }
    });
  }

  Future<void> _persistSkippedItems({
    required SyncTarget target,
    required Map<String, Object?> manifestResponse,
  }) async {
    for (final item in _skippedItems(manifestResponse)) {
      final itemId = item['item_id'] as String?;
      if (itemId == null || itemId.isEmpty) {
        continue;
      }
      await _repository.upsertItemState(
        SyncItemState(
          serverId: target.serverId,
          rootId: target.rootId,
          deviceId: target.deviceId,
          itemId: itemId,
          status: item['status'] as String? ?? 'skipped',
          localPath: item['local_path'] as String?,
          existingLocalPath: item['existing_local_path'] as String?,
          syncedAt: DateTime.now(),
        ),
      );
    }
  }

  List<String> _requestedUploadItemIds(Map<String, Object?> response) {
    final upload = response['upload'];
    if (upload is! List<Object?>) {
      return const [];
    }
    return upload
        .whereType<Map<Object?, Object?>>()
        .map((entry) => entry['item_id'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
  }

  String _terminalStatusFromUpload(Map<String, Object?> response) {
    final status = response['status'] as String?;
    if (status == 'success') {
      return response['imported'] == true ? 'imported' : 'uploaded';
    }
    return status ?? 'uploaded';
  }

  List<Map<Object?, Object?>> _skippedItems(Map<String, Object?> response) {
    final skip = response['skip'];
    if (skip is! List<Object?>) {
      return const [];
    }
    return skip.whereType<Map<Object?, Object?>>().toList();
  }

  int _skippedItemCount(Map<String, Object?> response) {
    return _skippedItems(response).length;
  }

  SyncTarget _targetFromPairing(
    PairingPayload payload,
    Map<String, Object?> response,
    DateTime now,
  ) {
    return SyncTarget(
      serverId: response['server_id'] as String? ?? payload.serverId,
      rootId: response['root_id'] as String? ?? payload.rootId,
      baseUrl: payload.baseUrl,
      pairingToken: payload.pairingToken,
      syncToken: response['sync_token'] as String?,
      syncTokenExpiresAt: _dateFromResponse(response['sync_token_expires_at']),
      destinationRoot: response['destination_root'] as String?,
      deviceId: _deviceId,
      deviceType: response['device_type'] as String? ?? 'android',
      deviceName: _deviceName,
      batchSize: response['batch_size'] as int? ?? _manifestBatchSize,
      pairedAt: now,
      updatedAt: now,
    );
  }

  SyncManifestItem _manifestItemFromAsset(PhotoAsset asset) {
    final filename = asset.displayName ?? '${asset.id}.jpg';
    return SyncManifestItem(
      itemId: asset.id,
      filename: filename,
      mediaType: switch (asset.mediaType) {
        PhotoMediaType.image => 'image',
      },
      mimeType: _mimeTypeFor(filename),
      size: asset.sizeBytes,
      createdAt: asset.createdAt,
      modifiedAt: asset.createdAt,
      timezone: DateTime.now().timeZoneName,
      width: asset.width,
      height: asset.height,
    );
  }

  DateTime? _dateFromResponse(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String _mimeTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    if (lower.endsWith('.mov')) {
      return 'video/quicktime';
    }
    return 'image/jpeg';
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return value.toLocal().toIso8601String();
  }

  String _formatToken(String? token) {
    if (token == null || token.isEmpty) {
      return '-';
    }
    if (token.length <= 12) {
      return token;
    }
    return '${token.substring(0, 8)}...';
  }

  String _manifestCountText(AppLocalizations l10n) {
    return _lastManifestCount == 0
        ? '-'
        : l10n
            .text('sync.lastManifestCountValue')
            .replaceAll('{count}', _lastManifestCount.toString())
            .replaceAll('{uploadedCount}', _lastUploadCount.toString())
            .replaceAll('{skipCount}', _lastSkipCount.toString())
            .replaceAll('{failureCount}', _lastFailureCount.toString());
  }

  String _uploadProgressText(AppLocalizations l10n) {
    if (_currentUploadName == null || _currentUploadTotal == 0) {
      return '-';
    }
    return l10n
        .text('sync.uploadProgressValue')
        .replaceAll('{index}', _currentUploadIndex.toString())
        .replaceAll('{total}', _currentUploadTotal.toString())
        .replaceAll('{filename}', _currentUploadName!);
  }

  void _applyLastBatchResult(_SyncBatchResult result) {
    _lastManifestCount = result.manifestCount;
    _lastUploadCount = result.uploadedCount;
    _lastSkipCount = result.skipCount;
    _lastFailureCount = result.failureCount;
  }

  String _batchMessage(AppLocalizations l10n, _SyncBatchResult result) {
    if (result.manifestCount == 0) {
      return l10n.text('sync.completeMessage');
    }
    return l10n
        .text('sync.manifestSent')
        .replaceAll('{count}', result.manifestCount.toString())
        .replaceAll('{uploadedCount}', result.uploadedCount.toString())
        .replaceAll('{skipCount}', result.skipCount.toString())
        .replaceAll('{failureCount}', result.failureCount.toString());
  }

  String _autoMessage(AppLocalizations l10n) {
    if (_syncComplete && _autoBatchCount == 0) {
      return l10n.text('sync.completeMessage');
    }
    return l10n
        .text('sync.autoSummary')
        .replaceAll('{batchCount}', _autoBatchCount.toString())
        .replaceAll('{count}', _autoManifestCount.toString())
        .replaceAll('{uploadedCount}', _autoUploadCount.toString())
        .replaceAll('{skipCount}', _autoSkipCount.toString())
        .replaceAll('{failureCount}', _autoFailureCount.toString());
  }

  String _friendlyError(AppLocalizations l10n, Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (error is SocketException ||
        lower.contains('connection refused') ||
        lower.contains('connection timed out') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable')) {
      return l10n.text('sync.errorPcUnreachable');
    }
    if (error is HttpException &&
        (lower.contains('invalid sync token') ||
            lower.contains('expired') ||
            lower.contains('token'))) {
      return l10n.text('sync.errorTokenExpired');
    }
    if (lower.contains('photo permission') ||
        lower.contains('permission_denied') ||
        lower.contains('permission is not granted')) {
      return l10n.text('sync.errorPermission');
    }
    if (lower.contains('upload body is empty') ||
        lower.contains('asset_read_failed') ||
        lower.contains('asset_not_found')) {
      return l10n.text('sync.errorUploadRead');
    }
    if (error is HttpException) {
      return l10n
          .text('sync.errorServer')
          .replaceAll('{detail}', error.message);
    }
    return raw;
  }

  VoidCallback? _pairAction() {
    if (_isPairing || _payloadController.text.trim().isEmpty) {
      return null;
    }
    return _pairWithDesktop;
  }

  VoidCallback? _scanQrAction() {
    if (_isPairing || _syncInProgress) {
      return null;
    }
    return _scanPairingQr;
  }

  VoidCallback? _manifestAction() {
    if (_isPairing || _isSendingManifest || _isAutoSyncing) {
      return null;
    }
    return _sendManifestBatch;
  }

  VoidCallback? _autoSyncAction() {
    if (_isPairing || _isSendingManifest || _isAutoSyncing) {
      return null;
    }
    return _startAutoSync;
  }

  Widget _buttonProgress() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  void _onPayloadChanged(String value) {
    setState(() {});
  }

  void _changePairing() {
    if (_syncInProgress) {
      return;
    }
    setState(() {
      _target = null;
      _message = null;
      _payloadController.clear();
    });
  }

  String _formatPayloadForDisplay(String rawPayload) {
    final trimmed = rawPayload.trim();
    try {
      final decoded = jsonDecode(trimmed);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } on FormatException {
      return trimmed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = _target;

    return PopScope(
      canPop: !_syncInProgress,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldLeave = await _confirmLeaveDuringSync();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.text('sync.title')),
        ),
        body: target == null
            ? _PairingView(
                payloadController: _payloadController,
                isPairing: _isPairing,
                message: _message,
                onPayloadChanged: _onPayloadChanged,
                onPair: _pairAction(),
                onScanQr: _scanQrAction(),
                buttonProgress: _buttonProgress,
              )
            : _SyncView(
                target: target,
                message: _message,
                syncPhase: _syncPhase,
                syncComplete: _syncComplete,
                recentFailures: _recentFailures,
                uploadProgressText: _uploadProgressText(l10n),
                autoMessage: _autoMessage(l10n),
                manifestCountText: _manifestCountText(l10n),
                formattedLastSyncedAt: _formatDate(target.lastSyncedAt),
                formattedSyncToken: _formatToken(target.syncToken),
                isSendingManifest: _isSendingManifest,
                isAutoSyncing: _isAutoSyncing,
                isStoppingAutoSync: _stopAutoSyncRequested,
                onSendManifest: _manifestAction(),
                onAutoSync: _autoSyncAction(),
                onStopAutoSync: _isAutoSyncing && !_stopAutoSyncRequested
                    ? _stopAutoSync
                    : null,
                onChangePairing: _syncInProgress ? null : _changePairing,
                buttonProgress: _buttonProgress,
              ),
      ),
    );
  }
}

class _PairingView extends StatelessWidget {
  const _PairingView({
    required this.payloadController,
    required this.isPairing,
    required this.message,
    required this.onPayloadChanged,
    required this.onPair,
    required this.onScanQr,
    required this.buttonProgress,
  });

  final TextEditingController payloadController;
  final bool isPairing;
  final String? message;
  final ValueChanged<String> onPayloadChanged;
  final VoidCallback? onPair;
  final VoidCallback? onScanQr;
  final Widget Function() buttonProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.text('sync.pairingIntro'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: payloadController,
          onChanged: onPayloadChanged,
          minLines: 5,
          maxLines: 12,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: l10n.text('sync.pairingPayload'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onPair,
              icon: isPairing
                  ? buttonProgress()
                  : const Icon(Icons.qr_code_scanner_outlined),
              label: Text(l10n.text('sync.pairAndSave')),
            ),
            OutlinedButton.icon(
              onPressed: onScanQr,
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(l10n.text('sync.scanQr')),
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!),
        ],
      ],
    );
  }
}

class _SyncView extends StatelessWidget {
  const _SyncView({
    required this.target,
    required this.message,
    required this.syncPhase,
    required this.syncComplete,
    required this.recentFailures,
    required this.uploadProgressText,
    required this.autoMessage,
    required this.manifestCountText,
    required this.formattedLastSyncedAt,
    required this.formattedSyncToken,
    required this.isSendingManifest,
    required this.isAutoSyncing,
    required this.isStoppingAutoSync,
    required this.onSendManifest,
    required this.onAutoSync,
    required this.onStopAutoSync,
    required this.onChangePairing,
    required this.buttonProgress,
  });

  final SyncTarget target;
  final String? message;
  final String? syncPhase;
  final bool syncComplete;
  final List<String> recentFailures;
  final String uploadProgressText;
  final String autoMessage;
  final String manifestCountText;
  final String formattedLastSyncedAt;
  final String formattedSyncToken;
  final bool isSendingManifest;
  final bool isAutoSyncing;
  final bool isStoppingAutoSync;
  final VoidCallback? onSendManifest;
  final VoidCallback? onAutoSync;
  final VoidCallback? onStopAutoSync;
  final VoidCallback? onChangePairing;
  final Widget Function() buttonProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.text('sync.readyIntro'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isAutoSyncing)
              FilledButton.icon(
                onPressed: onStopAutoSync,
                icon: isStoppingAutoSync
                    ? buttonProgress()
                    : const Icon(Icons.stop_circle_outlined),
                label: Text(
                  l10n.text(
                    isStoppingAutoSync
                        ? 'sync.stoppingAutoSync'
                        : 'sync.stopAutoSync',
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: onAutoSync,
                icon: const Icon(Icons.play_arrow_outlined),
                label: Text(l10n.text('sync.autoSync')),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onSendManifest,
                    icon: isSendingManifest
                        ? buttonProgress()
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.text('sync.sendManifest')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChangePairing,
                    icon: const Icon(Icons.qr_code_2_outlined),
                    label: Text(l10n.text('sync.changePairing')),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!),
        ],
        const SizedBox(height: 20),
        _StatusCard(
          title: l10n.text('sync.progressTitle'),
          rows: [
            _StatusRow(l10n.text('sync.phase'), syncPhase ?? '-'),
            _StatusRow(l10n.text('sync.uploadProgress'), uploadProgressText),
            _StatusRow(l10n.text('sync.autoTotals'), autoMessage),
            _StatusRow(
              l10n.text('sync.resumePolicy'),
              l10n.text('sync.resumePolicyValue'),
            ),
            _StatusRow(
              l10n.text('sync.completeStatus'),
              syncComplete ? l10n.text('sync.completeYes') : '-',
            ),
          ],
        ),
        if (recentFailures.isNotEmpty) ...[
          const SizedBox(height: 12),
          _StatusCard(
            title: l10n.text('sync.recentFailures'),
            rows: [
              for (final failure in recentFailures)
                _StatusRow(l10n.text('sync.failure'), failure),
            ],
          ),
        ],
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.text('sync.savedTarget'),
          rows: [
            _StatusRow(l10n.text('sync.server'), target.serverId),
            _StatusRow(l10n.text('sync.root'), target.rootId),
            _StatusRow(l10n.text('sync.baseUrl'), target.baseUrl),
            _StatusRow(l10n.text('sync.syncToken'), formattedSyncToken),
            _StatusRow(
              l10n.text('sync.destinationRoot'),
              target.destinationRoot ?? l10n.text('sync.waitingForPair'),
            ),
            _StatusRow(l10n.text('sync.lastSyncedAt'), formattedLastSyncedAt),
            _StatusRow(l10n.text('sync.lastManifestCount'), manifestCountText),
          ],
        ),
        const SizedBox(height: 12),
        _StatusCard(
          title: l10n.text('sync.v1Scope'),
          rows: [
            _StatusRow(
              l10n.text('sync.phoneRole'),
              l10n.text('sync.phoneRoleValue'),
            ),
            _StatusRow(
              l10n.text('sync.desktopRole'),
              l10n.text('sync.desktopRoleValue'),
            ),
            _StatusRow(
              l10n.text('sync.uploadMode'),
              l10n.text('sync.uploadModeValue'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_StatusRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 128,
                      child: Text(
                        row.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Text(row.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow {
  const _StatusRow(this.label, this.value);

  final String label;
  final String value;
}

class _UploadBatchResult {
  const _UploadBatchResult({
    required this.uploadedCount,
    required this.failureCount,
  });

  final int uploadedCount;
  final int failureCount;
}

class _SyncBatchResult {
  const _SyncBatchResult({
    required this.manifestCount,
    required this.uploadedCount,
    required this.skipCount,
    required this.failureCount,
  });

  const _SyncBatchResult.empty()
      : manifestCount = 0,
        uploadedCount = 0,
        skipCount = 0,
        failureCount = 0;

  final int manifestCount;
  final int uploadedCount;
  final int skipCount;
  final int failureCount;
}
