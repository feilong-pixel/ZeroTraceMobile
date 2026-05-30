# Product Design

ExtraSync is a focused phone companion for ZeroTraceBrowser. The first
shipping version uploads original phone photos to a paired PC over local Wi-Fi.

## Purpose

- Help the user move phone photos into a ZeroTraceBrowser-managed workspace.
- Keep import policy, hashing, duplicate checks, and organization on the PC.
- Keep the phone UI small enough to trust during repeated sync runs.

## Current Features

- Pair with ZeroTraceBrowser by scanning or pasting a QR payload.
- Save one paired desktop target.
- Send photo metadata manifest batches from the Android media library.
- Upload only the original photos requested by the PC.
- Run continuous automatic sync and stop it from the phone.
- Show progress, current upload, totals, resume policy, and recent failures.

## Sync Status UI

The phone-side sync status visualization is considered implemented for the
current Android scope.

The sync page shows:

- current sync phase
- current upload filename and index within the requested upload set
- visible photo total, completed terminal count, and remaining count for the
  current paired target
- automatic sync totals for batches, manifest items, uploads, skips, and
  failures
- last manifest result
- recent upload failures
- resume policy copy
- saved target details and last synced time
- stop state while Auto Sync is stopping

This UI is intentionally operational rather than managerial. It helps the user
understand what the phone is doing during the current sync run, but it does not
turn the phone into the system of record.

## Background Transfer

Background transfer is an Android-only capability for Auto Sync.

The first implementation uses an Android foreground service while Auto Sync is
active. The service shows a persistent notification and marks the work as a
data-sync task so Android treats the upload as an active user-visible transfer
when the app is backgrounded or the screen is locked.

Current boundary:

- Auto Sync starts the foreground service.
- Auto Sync completion, failure, or user stop stops the foreground service.
- The existing Flutter Auto Sync loop still owns batching and upload logic.
- This improves survival while the app is backgrounded, but it is not a
  killed-process recovery queue.
- If Android or the user force-stops the app process, the user should reopen the
  app and start Auto Sync again. Previously persisted terminal item state still
  prevents already completed items from being uploaded again.

## Transfer Conditions And Pace

Photo upload should stay predictable and gentle.

Required transfer condition:

- Upload photos only while the Android device is on Wi-Fi.
- If the device leaves Wi-Fi, Auto Sync should pause or stop before continuing
  more uploads.
- Do not automatically resume in the background after Wi-Fi returns. The user
  should explicitly start Auto Sync again.
- Already completed terminal items remain recorded, so a manual restart can
  continue without re-uploading completed items.

Gentle transfer:

- The sync page should expose a `Gentle Transfer` setting near the Auto Sync
  controls.
- The setting should use levels 1 through 5.
- Default level: 3.
- Level mapping:

```text
1 -> 100 ms after each uploaded item
2 -> 200 ms after each uploaded item
3 -> 300 ms after each uploaded item
4 -> 400 ms after each uploaded item
5 -> 500 ms after each uploaded item
```

The option is a user-facing pace control, not an automatic idle detector. It
should reduce continuous upload pressure without adding complex phone-idle
monitoring.

Do not add a fixed pause after every 10-item batch. The per-photo gentle delay
is enough for the current scope, and an extra batch pause may look like the app
has stalled.

## Management Boundary

The phone app should remain a light sync client.

The phone owns:

- pairing input and saved target selection
- Android photo permission and MediaStore enumeration
- manifest sending
- requested original-byte upload
- current-run status display
- local terminal item state used only for resume/skip behavior

ZeroTraceBrowser on the PC owns:

- import destination and root selection
- import history
- duplicate decisions
- locally-deleted marker decisions
- final imported/skipped state
- long-term sync/device management
- any future record browsing, reset, cleanup, or audit workflow

Therefore, ExtraSync should not add a phone-side sync history or management
page. Features such as terminal-count browsing, failed-item management, duplicate
review, deleted-local review, reset-current-target, or clear-sync-state belong
on the PC side unless this product boundary is deliberately changed later.

## Explicit Non-Goals

- No on-device duplicate scan in the current mobile app.
- No on-device similar-photo detection in the current mobile app.
- No cleanup review workflow on the phone.
- No phone-side photo deletion or reorganization.
- No phone-side sync history or sync-state management page.
- No cloud upload path.

## Future Placeholder

Similar Photos remains visible as a disabled entry so the product direction is
clear, but it should not be wired until the upload path is stable and the PC-side
import workflow has enough real data.

## First Screen

The dashboard should make the current job obvious:

- short upload-focused description
- primary Phone Sync action
- disabled Similar Photos placeholder
- settings access

The dashboard should not show scan counts, duplicate counts, cleanup estimates,
or review actions.
