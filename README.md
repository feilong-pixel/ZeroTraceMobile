# ZeroTraceMobile

ZeroTraceMobile is the Android phone companion for ZeroTraceBrowser. Its first
version focuses on one practical job: upload original phone photos to a paired PC
over local Wi-Fi.

The phone app sends photo metadata first, then uploads only the original files
requested by the desktop side. ZeroTraceBrowser owns the destination root, import
state, hashing, duplicate checks, and final organization.

## Current Scope

- Pair with ZeroTraceBrowser by scanning or pasting a desktop pairing QR payload.
- Send manifest batches from the Android media library.
- Upload requested original photos to the paired PC.
- Run automatic continuous sync and stop it safely.
- Keep a disabled Similar Photos entry as a future feature placeholder.

Features such as on-device duplicate scanning, cleanup review, and deletion are
not part of the current mobile app scope.

## Project Layout

```text
app/                         Flutter Android application
  lib/
    main.dart                 App entrypoint
    src/
      app/                    App composition, routing, theme
      features/
        dashboard/            Upload-focused home screen
        sync/                 Pairing, manifest, upload, auto-sync UI
        settings/             Pairing and scope copy
      shared/                 I18n, settings, storage, platform adapters

core/                        Reserved for future portable logic
docs/                        Product, architecture, safety notes
```

The active platform implementation is Android. A small iPhone photo-library
interface stub is kept so PhotoKit support can be added later without reshaping
the sync feature.

## Safety Model

- Photos are sent only to the paired PC on the local network.
- The phone does not delete or reorganize photos.
- Sync can be stopped from the phone UI.
- Imported, duplicate, and locally-deleted states reported by the desktop side
  are skipped on later sync runs.
