# ExtraSync v0.2.0 Release Notes

Status: final release notes for the Android phone-to-PC sync build.

## Highlights

- Android phone-to-PC sync has been accepted on a real Android phone and PC.
- QR pairing with ZeroTraceBrowser is supported.
- Single Sync Once transfer is supported.
- Auto Sync transfer is supported.
- Active Auto Sync can continue while the app is backgrounded or the screen is
  locked, using an Android foreground-service notification.
- Upload is Wi-Fi only. If Wi-Fi is unavailable, the app does not upload more
  original bytes and the user can restart sync manually after returning to
  Wi-Fi.
- Gentle Transfer levels 1-5 let the user pace uploads from 100ms to 500ms
  after each uploaded item. The default level is 3.
- Manifest transfer runs in 10-item batches.
- Stop during Auto Sync is cooperative: the app finishes the current batch
  boundary before stopping.
- Resume behavior is based on local terminal item state, keyed by
  `server_id + root_id + device_id + item_id`.
- Uploaded photos on the PC were verified as readable and usable in the tested
  run.
- Sync totals were verified as credible in the tested run.

## Sync Behavior

The phone sends metadata first and uploads only original photo bytes requested by
ZeroTraceBrowser. The desktop remains the authority for import destination,
duplicate decisions, local deleted-marker decisions, hashing, and final import
state.

The phone skips terminal items already recorded in local SQLite for the current
desktop target and device. Current terminal states are:

```text
imported
already_imported
skipped_duplicate
skipped_deleted_locally
uploaded
```

`failed` is intentionally not terminal, so failed items can be retried by a
later manual batch or Auto Sync run.

## Install

Install `ExtraSync-v0.2.0-android.apk` on Android and pair it with
ZeroTraceBrowser on the same local Wi-Fi.

SHA256:

```text
73894EFD3538BDA4A69ADD19D767DFCB22F4D89C8BC022E9A1F071A3DACA9FCA
```

## Notes

- This release remains Android-first.
- The phone app does not delete, reorganize, or clean up photos on the device.
- Similar Photos remains a disabled placeholder.
