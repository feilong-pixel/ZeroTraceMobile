# Storage and Platform Boundaries

ZeroTraceMobile keeps all internal runtime data inside the app-private sandbox
assigned by iOS or Android. Runtime paths in this document are logical paths;
they must be resolved through platform APIs such as Flutter `path_provider`,
NSUserDefaults, SharedPreferences, PhotoKit, and MediaStore.

Do not hard-code public directories such as shared downloads, public documents,
or the photo library for internal cache, database, or preference files.

## Runtime Directories

```text
<app-private-cache>/
  thumbnails/
    images/
      <asset_id_hash>_<width>x<height>.jpg

<app-private-application-support>/
  zerotrace_mobile.sqlite

<app-private-preferences>/
  app preferences managed by NSUserDefaults or SharedPreferences
```

These directories are scoped by the operating system to the current app bundle
id or Android package name. They must not conflict with other apps.

## Thumbnails

The app should request thumbnails from the platform photo library first:

- iOS uses PhotoKit thumbnail APIs.
- Android uses MediaStore, Photo Picker, or platform image-loading helpers.

The app may keep its own thumbnail cache for stable review performance and fast
first paint. Thumbnail cache files are derived data and may be deleted by the
system or by the app without losing user decisions.

Thumbnail cache rules:

- store thumbnails under the app-private cache directory
- key files by a stable hash of the platform asset id plus requested size
- keep thumbnail binaries out of SQLite
- regenerate missing thumbnails from the platform asset id
- never write internal thumbnails into the user's photo library

## SQLite Database

The app database is persistent app-private state and belongs under application
support, not cache.

SQLite stores:

- scan runs
- asset metadata cache
- exact content hashes
- perceptual hashes
- duplicate groups
- ignored groups
- user keep decisions
- cleanup audit records

The photo library remains the source of truth before any destructive action.
Before deletion, the app must recheck that each platform asset still exists and
then use the platform-confirmed deletion flow.

## Preferences

Lightweight user preferences should use app-scoped preferences:

- iOS: NSUserDefaults
- Android: SharedPreferences
- Flutter: a small repository abstraction over the platform-backed store

Preferences include language, theme, default scan options, review sorting,
thumbnail sizing, first-run flags, and safety-related UI choices.

Preferences should not duplicate large scan results or review plans. Those
belong in SQLite when they need to survive app restarts.

## Platform Bridge

Flutter owns the shared platform contract:

```text
app/lib/src/shared/platform/
  photo_library.dart
  photo_asset.dart
  photo_permission.dart
  photo_library_channel.dart
```

Native code owns operating-system details:

```text
native/ios/
  PhotoKit asset enumeration
  PhotoKit thumbnail loading
  PhotoKit deletion requests

native/android/
  MediaStore or Photo Picker asset enumeration
  thumbnail loading
  system deletion requests
```

The platform bridge should expose a small typed surface to Flutter:

- request photo access
- enumerate photo assets
- load thumbnails
- open original bytes or streams for hashing
- request system-confirmed deletion
- report platform-specific result details

The bridge must not implement grouping, ranking, or duplicate-detection policy.
Those decisions belong to the app services and core engine boundary.

## Exported Files

Reports, logs, or user-visible exports are separate from internal runtime data.
They should only be written after an explicit user action and should use the
platform share sheet, document picker, or another user-selected destination.
