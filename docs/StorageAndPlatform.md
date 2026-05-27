# Storage And Platform

## Storage Scope

The mobile database stores only sync state needed by the phone client:

- paired desktop targets
- sync token and destination metadata
- terminal item states returned by ZeroTraceBrowser

The active tables are:

- `sync_targets`
- `sync_items`

The phone does not persist scan runs, duplicate groups, review decisions, cleanup
plans, or deletion audit records in the current product scope.

## Resume State

`sync_items` stores server/root/device/item status so later manifest batches can
skip terminal items. Terminal states are decided by the desktop side and may
include imported, duplicate, or deleted-local outcomes.

Failed upload attempts are left retryable.

## Platform Interface

`PhotoLibrary` is the platform boundary used by the sync screen:

- request permission
- enumerate photo metadata
- open original bytes

Android is implemented through `AndroidPhotoLibraryChannel` and the native
MediaStore bridge.

iPhone support is reserved through `IosPhotoLibraryChannel`. That class is a
stub until PhotoKit support is intentionally implemented.

## Out Of Scope

- thumbnail cache
- platform deletion requests
- cleanup audit records
- local duplicate/similar grouping
- phone-side photo reorganization
