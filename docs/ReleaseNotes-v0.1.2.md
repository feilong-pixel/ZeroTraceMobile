# ExtraSync v0.1.2 Release Notes

Status: release note draft for the Android sync acceptance build.

## Highlights

- Android phone-to-PC sync has been accepted on a real Android phone and PC.
- QR pairing with ZeroTraceBrowser is supported.
- Single Send Manifest Batch transfer is supported.
- Auto Sync transfer is supported.
- Manifest transfer runs in 10-item batches.
- Stop during Auto Sync is cooperative: the app finishes the current 10-item
  batch before stopping.
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

Install `ExtraSync-v0.1.2-android.apk` on Android and pair it with
ZeroTraceBrowser on the same local Wi-Fi.

## Notes

- This release remains Android-first.
- The phone app does not delete, reorganize, or clean up photos on the device.
- Similar Photos remains a disabled placeholder.
