# App Layer

This directory will contain the Flutter application.

The app layer owns:

- navigation
- localization
- UI state
- platform-channel adapters
- review and cleanup workflows

It should not own duplicate-detection algorithms. Those belong in `core/`.

## Planned Structure

```text
lib/
  main.dart
  src/
    app/
      mobile_app.dart
      routes.dart
      theme.dart
    features/
      dashboard/
      scan/
      duplicates/
      review/
      settings/
    shared/
      i18n/
      platform/
      settings/
      storage/
      thumbnails/
      widgets/
      models/
```

## Localization

The app currently supports English, Chinese, and Japanese through a lightweight
`LocalizationsDelegate` in `lib/src/shared/i18n/`.

English is the default fallback language. User-selectable language persistence
will be added after settings persistence is introduced.

## Storage

SQLite storage lives under `lib/src/shared/storage/`.

The first schema stores scan runs, scanned image metadata, exact/perceptual
hashes, duplicate groups, and group members. The photo library remains the
source of truth before deletion; the database is used for scan cache, review
state, and resumable workflows.

The database file belongs in the app-private application support directory.
Thumbnail binaries belong in the app-private cache directory under a
`thumbnails/` namespace and should be regenerated when missing. Lightweight
preferences such as language, theme, default scan options, and review sorting
live behind `lib/src/shared/settings/`.

See `../docs/StorageAndPlatform.md` for the runtime directory policy and the
iOS/Android bridge split.

## Platform Contract

The shared platform interface starts in `lib/src/shared/platform/`:

- `PhotoLibrary` defines permission, enumeration, thumbnail, original-byte, and
  deletion operations.
- `PhotoLibraryChannel` is the placeholder for the eventual method-channel or
  FFI bridge.
- iOS and Android implementations stay outside shared UI code.

Settings and thumbnail repositories are intentionally thin at first so app code
depends on stable interfaces before native storage and bridge details are wired.
