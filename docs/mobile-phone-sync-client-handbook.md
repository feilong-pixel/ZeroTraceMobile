# ExtraSync Phone Sync Client Handbook

This file is a compact handoff note for implementing the phone-side client in
ExtraSync. The desktop implementation lives in ZeroTraceBrowser.

Main reference:

- `docs/photo-import-design.md`

## Goal

The phone app uploads original photo bytes to ZeroTraceBrowser over local Wi-Fi.
The desktop remains the authority for:

- destination root
- duplicate detection
- local deleted markers
- final import state
- SHA-256 calculation

The phone should avoid heavy hash work in v1. It should discover local photo
assets, send metadata first, then upload only items requested by the desktop.

## API List

```text
GET  /api/mobile/sync/pairing-code
POST /api/mobile/pair
POST /api/mobile/sync/start
POST /api/mobile/sync/manifest
POST /api/mobile/sync/upload
GET  /api/mobile/sync/status
```

## Pairing QR Payload

The desktop page returns a QR payload from:

```text
GET /api/mobile/sync/pairing-code
```

The QR contains JSON like:

```json
{
  "protocol": "zerotrace-phone-sync",
  "version": 1,
  "server_id": "ztb-...",
  "root_id": "...",
  "base_url": "http://192.168.x.x:8000",
  "pairing_token": "pair-...",
  "pair_url": "http://192.168.x.x:8000/api/mobile/pair",
  "sync_start_url": "http://192.168.x.x:8000/api/mobile/sync/start",
  "manifest_url": "http://192.168.x.x:8000/api/mobile/sync/manifest",
  "upload_url": "http://192.168.x.x:8000/api/mobile/sync/upload",
  "status_url": "http://192.168.x.x:8000/api/mobile/sync/status",
  "expires_at": "2026-05-24T10:30:00+00:00"
}
```

The phone should validate:

- `protocol == "zerotrace-phone-sync"`
- `version == 1`
- `base_url` is present
- `pairing_token` is present

## Minimum Phone Flow

```text
scan QR
  -> save server_id / root_id / base_url / pairing_token
  -> POST /api/mobile/pair
  -> save sync_token returned by desktop
  -> POST /api/mobile/sync/start
  -> scan local photo asset metadata
  -> POST /api/mobile/sync/manifest
  -> upload each item requested in response.upload
  -> record final item status returned by desktop
```

## Pair Device

Request:

```text
POST /api/mobile/pair
Content-Type: application/json
```

Example body:

```json
{
  "pairing_token": "pair-...",
  "device_type": "iphone",
  "device_id": "stable-phone-id",
  "device_name": "User iPhone",
  "device_model": "iPhone",
  "platform": "ios",
  "app_id": "zerotrace-mobile",
  "app_version": "0.1.1",
  "owner_label": "User",
  "capabilities": {
    "asset_id": true,
    "raw_upload": true
  }
}
```

Important response fields:

```json
{
  "status": "paired",
  "server_id": "ztb-...",
  "root_id": "...",
  "destination_root": "I:\\Photos_20260518",
  "sync_token": "sync-...",
  "sync_token_expires_at": "2026-05-24T10:30:00+00:00",
  "batch_size": 10,
  "accepted_types": [".jpg", ".jpeg", ".png"],
  "duplicate_policy": "strict_skip",
  "deleted_marker_policy": "skip_deleted_locally"
}
```

The phone should persist the returned `sync_token`.

## Start Sync

Request:

```text
POST /api/mobile/sync/start
Content-Type: application/json
```

Example body:

```json
{
  "device_type": "iphone",
  "device_id": "stable-phone-id",
  "sync_token": "sync-...",
  "last_client_cursor": "",
  "battery_state": "charging",
  "network_type": "wifi"
}
```

Important response fields:

```json
{
  "status": "ready",
  "session_id": "phone-sync-...",
  "server_id": "ztb-...",
  "root_id": "...",
  "destination_root": "I:\\Photos_20260518",
  "batch_size": 10,
  "server_cursor": "..."
}
```

The phone should use `session_id` for manifest and upload calls.

## Send Manifest

The phone sends candidate asset metadata before uploading bytes.

Request:

```text
POST /api/mobile/sync/manifest
Content-Type: application/json
```

Example body:

```json
{
  "session_id": "phone-sync-...",
  "device_type": "iphone",
  "device_id": "stable-phone-id",
  "items": [
    {
      "item_id": "local-asset-id",
      "filename": "IMG_0001.JPG",
      "media_type": "image",
      "mime_type": "image/jpeg",
      "size": 2480000,
      "created_at": "2026-05-24T10:00:00+00:00",
      "modified_at": "2026-05-24T10:01:00+00:00",
      "timezone": "Asia/Tokyo",
      "album": "Recents",
      "width": 4032,
      "height": 3024,
      "duration_ms": 0
    }
  ]
}
```

Response example:

```json
{
  "status": "accepted",
  "session_id": "phone-sync-...",
  "upload_batch_id": "batch-...",
  "upload": [
    {
      "item_id": "local-asset-id",
      "upload_url": "/api/mobile/sync/upload",
      "status": "upload_required"
    }
  ],
  "skip": [],
  "batch_size": 10,
  "destination_root": "I:\\Photos_20260518"
}
```

The phone should upload only items listed in `upload`.

## Upload Bytes

Current desktop implementation does not use multipart.

Request:

```text
POST /api/mobile/sync/upload
X-ZTB-Mobile-Metadata: <JSON string>
Body: original media bytes
```

Metadata header example:

```json
{
  "session_id": "phone-sync-...",
  "device_type": "iphone",
  "device_id": "stable-phone-id",
  "item_id": "local-asset-id",
  "filename": "IMG_0001.JPG",
  "created_at": "2026-05-24T10:00:00+00:00",
  "modified_at": "2026-05-24T10:01:00+00:00"
}
```

The HTTP body must be the original photo or video bytes.

Success response:

```json
{
  "status": "success",
  "imported": true,
  "item_id": "local-asset-id",
  "file": "IMG_0001.JPG",
  "local_path": "I:\\Photos_20260518\\2026\\05\\24\\IMG_0001.JPG",
  "sha256": "...",
  "phash": "...",
  "size": 2480000,
  "destination_root": "I:\\Photos_20260518"
}
```

Duplicate response:

```json
{
  "status": "skipped_duplicate",
  "imported": false,
  "item_id": "local-asset-id",
  "file": "IMG_0001.JPG",
  "sha256": "...",
  "existing_local_path": "I:\\Photos_20260518\\2026\\05\\24\\IMG_0001.JPG",
  "size": 2480000
}
```

Deleted-local response:

```json
{
  "status": "skipped_deleted_locally",
  "imported": false,
  "item_id": "local-asset-id",
  "file": "IMG_0001.JPG",
  "sha256": "...",
  "size": 2480000,
  "deleted_at": "2026-05-24T10:02:00+00:00",
  "deleted_relative_path": "2026/05/24/IMG_0001.JPG",
  "delete_source": "local_gallery"
}
```

The phone should treat all three statuses as terminal for that `item_id` on this
`server_id + root_id`.

## Status Polling

Request:

```text
GET /api/mobile/sync/status
```

Example response:

```json
{
  "status": "syncing",
  "destination_root": "I:\\Photos_20260518",
  "paired_devices": 1,
  "connected_devices": [
    {
      "device_type": "iphone",
      "device_id": "stable-phone-id",
      "status": "syncing",
      "last_seen_at": "2026-05-24T10:05:00+00:00"
    }
  ],
  "summary": {
    "processed": 128,
    "imported": 96,
    "skipped_duplicate": 32,
    "skipped_deleted_locally": 0,
    "failed": 0
  },
  "recent_events": []
}
```

## Phone-Side Persistence

The phone should persist:

```text
server_id
root_id
base_url
device_id
sync_token
last_client_cursor
last successful synced_at
item_id -> terminal status
item_id -> sha256 returned by desktop
```

Recommended terminal statuses:

```text
success
skipped_duplicate
skipped_deleted_locally
failed
```

For v1, the phone should avoid re-uploading a terminal item for the same
`server_id + root_id + device_id + item_id`.

## Auto Sync Batch and Resume Rules

The current Android Auto Sync implementation is batch-loop based.

Flow:

```text
Auto Sync button
  -> start one sync session
  -> read terminal item ids from local SQLite
  -> enumerate Android MediaStore assets
  -> collect up to 10 non-terminal items
  -> send manifest
  -> persist desktop skip decisions
  -> upload only desktop-requested item bytes
  -> persist terminal upload results
  -> repeat until no new candidate remains, a failure occurs, or stop is requested
```

Batch size:

- The current manifest batch size is 10 items.
- Stop is cooperative. When the user requests Stop during Auto Sync, the phone
  finishes the current 10-item batch before the loop exits.

How the phone decides what still needs work:

- The phone does not calculate SHA-256 in v1.
- The phone does not decide completion by filename.
- The phone reads local SQLite `sync_items` rows for the current
  `server_id + root_id + device_id`.
- Any Android asset whose `item_id` is already in a terminal state is skipped
  before sending the next manifest.
- Any Android asset not in a terminal state is eligible for the next manifest
  batch.

Current terminal states:

```text
imported
already_imported
skipped_duplicate
skipped_deleted_locally
uploaded
```

Current retry behavior:

- `failed` is not terminal.
- A failed item can be picked up again by a later Send Manifest Batch or Auto
  Sync run.

Identity:

```text
server_id + root_id + device_id + item_id
```

The phone uses this identity as the local resume key. The desktop remains the
authority for deciding whether a manifest item should be uploaded, skipped as a
duplicate, or skipped because it was deleted locally.

## Implemented Sync Status Display

The current Android sync page already implements the planned lightweight status
visualization. It should be treated as complete for the current scope, not as a
separate pending feature.

Implemented display items:

- sync phase: permission, starting session, enumerating, manifest, uploading,
  batch complete, complete, and stopping
- current upload progress: index, total, and filename
- photo count summary: visible asset total, terminal completed count for the
  current target, and remaining non-terminal count
- Auto Sync totals: batch count, manifest count, uploaded count, skipped count,
  and failure count
- last manifest result: manifest count, uploaded count, skipped count, and
  failure count
- recent failures, capped to the latest few entries
- resume policy copy explaining that terminal items are not uploaded again
- saved target details, including server, root, base URL, sync token preview,
  destination root, last synced time, and last manifest result
- active Stop Sync / Stopping state during Auto Sync
- navigation protection while sync is active

This status display is for current-run transparency only. It is not intended to
be a phone-side sync management console.

## Phone/PC Management Boundary

ExtraSync should stay a light client. It should not add a dedicated phone-side
sync history, terminal item browser, failed item management page, duplicate
review page, deleted-local review page, or manual sync-state reset page.

Those management capabilities belong on the ZeroTraceBrowser PC side because
the PC owns the destination root, duplicate policy, deleted-local markers, import
history, audit trail, and final state.

## Android Foreground Sync Service

Auto Sync uses an Android foreground service for background transfer support.

Implementation boundary:

- Flutter starts `BackgroundSyncService` when Auto Sync starts.
- Flutter stops `BackgroundSyncService` when Auto Sync exits, fails, or is
  stopped by the user.
- The service owns only Android foreground-service visibility and process
  priority.
- The existing Flutter sync loop still owns pairing state, manifest batching,
  upload requests, terminal item persistence, and UI counters.

Android declarations:

- `android.permission.FOREGROUND_SERVICE`
- `android.permission.FOREGROUND_SERVICE_DATA_SYNC`
- `android.permission.POST_NOTIFICATIONS`
- service foreground type: `dataSync`

This is intentionally a foreground user-visible upload, not a silent background
worker. It supports app-backgrounded or screen-locked transfer better than a pure
Activity-bound loop. It does not promise automatic recovery after the Android
process is force-stopped or killed.

## Wi-Fi Only And Gentle Transfer

Uploads should be guarded by a Wi-Fi-only rule.

Implementation guidance:

- Check the current Android network before starting Auto Sync.
- Check the current Android network before each original-byte upload.
- If Wi-Fi is unavailable, do not upload more original bytes.
- Surface a clear pause/stop reason in the sync UI.
- Existing terminal item state should make resume safe after the user returns to
  Wi-Fi and starts sync again.
- Do not automatically resume in the background when Wi-Fi comes back.
- The user must manually start Auto Sync again after returning to Wi-Fi.

Do not infer Wi-Fi by probing the PC URL. Use Android network state, exposed to
Flutter through a small platform API such as `ConnectivityManager` over a
MethodChannel.

Wi-Fi departure behavior:

- If Wi-Fi is unavailable before Auto Sync starts, refuse to start and show a
  clear message.
- If Wi-Fi disappears during Auto Sync, stop scheduling additional original-byte
  uploads and show that sync paused because Wi-Fi was lost.
- A currently in-flight single upload may finish or fail naturally; do not kill
  the request aggressively.
- Stop the foreground-service notification when Auto Sync exits.
- After the user returns to Wi-Fi, they can start Auto Sync again. Terminal item
  state prevents completed photos from being uploaded again.

This keeps the app light and user-controlled. Automatic network-change recovery
is intentionally out of scope for this step.

Gentle transfer should be user-controlled:

```text
level 1 = 100 ms delay after each uploaded item
level 2 = 200 ms delay after each uploaded item
level 3 = 300 ms delay after each uploaded item
level 4 = 400 ms delay after each uploaded item
level 5 = 500 ms delay after each uploaded item
```

Default level: 3.

UI placement:

- Put the control on the Phone Sync page.
- Place it near the Auto Sync / Sync Once controls, before the progress cards.
- Use a segmented 1-5 control or equivalent simple selector.
- Persist the selected level locally so the next sync uses the same pace.

This replaces complex phone-idle detection. Avoid polling CPU, memory, user
activity, or other app state. The first implementation should keep the rule
simple: user-initiated Auto Sync, Wi-Fi only, and a small per-photo delay.

Do not add a fixed delay after every 10-item manifest batch. That could make the
app look stuck. The 10-item batch boundary remains a protocol and progress unit,
while pacing is controlled per uploaded item.

## Identity Rules

Use stable identities:

```text
server_id + root_id + device_id + item_id
```

- `server_id`: identifies this ZeroTraceBrowser installation.
- `root_id`: identifies the current destination root.
- `device_id`: stable app/device identity generated or read by the phone app.
- `item_id`: stable local photo asset id from the phone OS.

If the desktop user changes sync target, new photos go to the new target.
Already terminal items should not be uploaded again unless the user explicitly
resets sync state.

## Important Notes

- The phone does not need to calculate SHA-256 in v1.
- The desktop calculates SHA-256 after receiving bytes.
- The desktop skips files that match local deleted markers.
- The desktop skips strict duplicates already present in the active root hash DB.
- Multiple phones may connect; the phone client should not assume it is the only
  active device.
- The upload API is raw bytes plus `X-ZTB-Mobile-Metadata`, not multipart.

