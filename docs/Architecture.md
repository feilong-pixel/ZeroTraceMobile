# Architecture

## Goals

- Upload phone photos to ZeroTraceBrowser over local Wi-Fi.
- Keep the phone app thin: pairing, manifest, upload, progress, and resume state.
- Keep hashing, duplicate policy, deleted-local policy, and final import state on
  the desktop side.
- Keep Android implementation active while preserving an iPhone platform
  interface for later.

## Layers

```text
Flutter UI
  - dashboard
  - phone sync screen
  - QR pairing scanner
  - settings copy

Sync Client
  - pair
  - start sync
  - send manifest
  - upload requested original bytes

Storage
  - paired desktop target
  - terminal sync item states for resume and skip behavior

Platform Photo Library
  - request photo permission
  - enumerate photo metadata
  - open original photo bytes

ZeroTraceBrowser
  - destination root
  - import policy
  - hash and duplicate decisions
  - deleted-local decisions
```

## Data Flow

```text
Desktop QR payload
  -> phone pairing
  -> saved sync target
  -> Android MediaStore metadata enumeration
  -> manifest batch
  -> desktop returns upload / skip decisions
  -> phone uploads requested originals
  -> phone stores terminal item states
```

## Platform Boundary

`PhotoLibrary` is the shared interface for both Android and future iPhone
support. The active Android implementation is `AndroidPhotoLibraryChannel`.
`IosPhotoLibraryChannel` is intentionally a stub until a PhotoKit bridge is
implemented.

The interface is intentionally small:

- request permission
- enumerate assets
- open original bytes

Deletion, thumbnail loading, local duplicate grouping, and cleanup review are
not part of the current mobile architecture.

## Persistence

SQLite storage lives in `app/lib/src/shared/storage/` and currently owns only
sync data:

- `sync_targets`
- `sync_items`

Older development databases may still contain early scan tables, but new
installations no longer create them.
