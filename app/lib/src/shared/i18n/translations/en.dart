const enMessages = {
  'app.title': 'ExtraSync',
  'nav.settings': 'Settings',
  'dashboard.tagline':
      'Send phone photos to ZeroTraceBrowser over local Wi-Fi.',
  'dashboard.phoneSync': 'Phone Sync',
  'dashboard.similarImages.title': 'Similar Photos',
  'dashboard.similarImages.value': 'Coming later. Upload photos first.',
  'settings.title': 'Settings',
  'settings.localOnly.title': 'Local Wi-Fi upload',
  'settings.localOnly.subtitle': 'Photos are sent only to your paired PC.',
  'settings.keepPreference.title': 'Pairing',
  'settings.keepPreference.subtitle':
      'Use Phone Sync to scan the desktop QR and save pairing.',
  'settings.clearCache.title': 'Similar Photos',
  'settings.clearCache.subtitle':
      'Not available yet. Detection will be planned after upload is stable.',
  'settings.language.title': 'Language',
  'settings.language.subtitle': 'English, Chinese, Japanese',
  'settings.theme.title': 'Theme',
  'settings.theme.system': 'Follow system',
  'settings.theme.light': 'Light',
  'settings.theme.dark': 'Dark',
  'sync.title': 'Phone Sync',
  'sync.intro':
      'Pair with ZeroTraceBrowser and upload original photos over local Wi-Fi.',
  'sync.pairingIntro':
      'Pair this phone with ZeroTraceBrowser before starting photo sync.',
  'sync.readyIntro':
      'This phone is paired. Start a sync batch or run automatic sync.',
  'sync.pairingPayload': 'Pairing QR payload JSON',
  'sync.savePairing': 'Save Pairing',
  'sync.pairAndSave': 'Pair and Save',
  'sync.scanQr': 'Scan QR',
  'sync.scanQrTitle': 'Scan Pairing QR',
  'sync.scanQrHint':
      'Point the camera at the ZeroTraceBrowser pairing QR on the PC.',
  'sync.scanQrFilled':
      'QR recognized and pairing JSON filled. Review it, then tap Pair and Save.',
  'sync.sendManifest': 'Sync Once',
  'sync.autoSync': 'Start Sync',
  'sync.stopAutoSync': 'Stop Sync',
  'sync.stoppingAutoSync': 'Stopping...',
  'sync.changePairing': 'Pair Another PC',
  'sync.pairingSaved': 'Pairing payload saved.',
  'sync.pairFirst': 'Pair with ZeroTraceBrowser before sending a manifest.',
  'sync.photoPermissionDenied': 'Photo permission is not available.',
  'sync.photoBridgeNotReady':
      'The native photo library bridge is not wired yet.',
  'sync.noManifestItems': 'No unsynced photo metadata found for this target.',
  'sync.completeMessage': 'Sync complete. No more unsynced photos.',
  'sync.manifestSent':
      'Manifest {count}: uploaded {uploadedCount}, skipped {skipCount}, failed {failureCount}.',
  'sync.autoStarted': 'Auto sync started.',
  'sync.stopRequested': 'Stop requested. Finishing the current item.',
  'sync.autoStopped': 'Auto sync stopped.',
  'sync.autoSummary':
      'Auto sync {batchCount} batches: manifest {count}, uploaded {uploadedCount}, skipped {skipCount}, failed {failureCount}.',
  'sync.phasePermission': 'Checking photo permission',
  'sync.phaseStarting': 'Starting sync session',
  'sync.phaseEnumerating': 'Enumerating phone photos',
  'sync.phaseManifest': 'Sending manifest',
  'sync.phaseUploading': 'Uploading original photo',
  'sync.phaseBatchComplete': 'Current batch complete',
  'sync.phaseComplete': 'No more unsynced photos',
  'sync.phaseStopping': 'Stopping after the current item',
  'sync.phaseWifiPaused': 'Left Wi-Fi; sync paused',
  'sync.progressTitle': 'Sync Progress',
  'sync.phase': 'Phase',
  'sync.uploadProgress': 'Current Upload',
  'sync.uploadProgressValue': '{index}/{total}: {filename}',
  'sync.photoCount': 'Photos',
  'sync.photoCountValue':
      '{totalCount} total / {terminalCount} done / {remainingCount} remaining',
  'sync.gentleTransfer': 'Gentle Transfer',
  'sync.gentleTransferValue':
      'Level {level}: wait {delayMs}ms after each upload.',
  'sync.autoTotals': 'Totals',
  'sync.resumePolicy': 'Resume',
  'sync.resumePolicyValue':
      'Imported, duplicate, and locally-deleted items will not upload again.',
  'sync.completeStatus': 'Complete',
  'sync.completeYes': 'Synced',
  'sync.recentFailures': 'Recent Failures',
  'sync.failure': 'Failed',
  'sync.leaveTitle': 'Sync is running',
  'sync.leaveBody':
      'Leaving this page may interrupt the current sync. Leave anyway?',
  'sync.leaveStay': 'Keep Syncing',
  'sync.leaveConfirm': 'Leave',
  'sync.errorPcUnreachable':
      'Cannot reach the PC. Check that both devices are on the same Wi-Fi, the PC service is running, and the pairing URL is not localhost.',
  'sync.errorTokenExpired':
      'The sync token is invalid or expired. Generate a new pairing QR on the PC and pair again.',
  'sync.errorPermission':
      'Photo permission is unavailable. Allow ExtraSync photo access in Android settings.',
  'sync.errorUploadRead':
      'Could not read the original photo. It may have moved, been deleted, or Android denied access.',
  'sync.errorServer': 'PC returned an error: {detail}',
  'sync.wifiRequired':
      'Connect to Wi-Fi before syncing. Photos upload only on Wi-Fi.',
  'sync.wifiLost':
      'Left Wi-Fi; sync paused. Return to Wi-Fi and start sync again manually.',
  'sync.savedTarget': 'Saved Target',
  'sync.server': 'Server',
  'sync.root': 'Root',
  'sync.baseUrl': 'Base URL',
  'sync.syncToken': 'Sync Token',
  'sync.destinationRoot': 'Destination',
  'sync.lastSyncedAt': 'Last Sync',
  'sync.lastManifestCount': 'Last Manifest',
  'sync.lastManifestCountValue':
      '{count} manifest / {uploadedCount} uploaded / {skipCount} skipped / {failureCount} failed',
  'sync.waitingForPair': 'Waiting for desktop pairing response',
  'sync.v1Scope': 'V1 Sync Scope',
  'sync.phoneRole': 'Phone',
  'sync.phoneRoleValue': 'Sends metadata first, then requested original bytes.',
  'sync.desktopRole': 'Desktop',
  'sync.desktopRoleValue': 'Owns hashes, duplicate checks, and final import.',
  'sync.uploadMode': 'Upload',
  'sync.uploadModeValue': 'Raw bytes with X-ZTB-Mobile-Metadata.',
};
