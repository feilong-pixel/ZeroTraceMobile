# App Layer

This directory contains the Flutter Android app for ZeroTraceMobile.

The app layer owns:

- pairing with ZeroTraceBrowser
- QR scan and manual pairing payload entry
- Android photo permission and MediaStore access
- manifest batch submission
- requested original-photo upload
- automatic sync and stop controls
- localization and app settings copy

It does not own desktop import policy, duplicate detection, cleanup review, or
photo deletion. Those decisions stay on the ZeroTraceBrowser side. Similar
Photos remains a disabled placeholder until upload behavior is stable enough to
plan that feature separately.

## Structure

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
      sync/
      settings/
    shared/
      i18n/
      platform/
      settings/
      storage/
      sync/
      widgets/
```

## Localization

The app currently supports English, Chinese, and Japanese through a lightweight
`LocalizationsDelegate` in `lib/src/shared/i18n/`.

English is the default fallback language.

## Storage

SQLite storage lives under `lib/src/shared/storage/`.

The current mobile database stores pairing and sync state needed to resume
uploads safely. Photo files remain in the Android media library; uploaded import
state is confirmed by ZeroTraceBrowser.

## Platform Contract

The shared platform interface starts in `lib/src/shared/platform/`:

- `PhotoLibrary` defines permission, enumeration, and original-byte access.
- `AndroidPhotoLibraryChannel` implements the active photo listing and upload
  path.
- `IosPhotoLibraryChannel` is a reserved iPhone bridge stub for later PhotoKit
  work.
