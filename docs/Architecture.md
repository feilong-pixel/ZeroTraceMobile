# Architecture

## Goals

- Keep photo content on device.
- Share core detection logic across iOS and Android.
- Make platform-specific photo access explicit and isolated.
- Allow fixture-driven engine tests without mobile simulators.
- Preserve a conservative deletion flow.

## Layers

```text
Flutter UI
  - screens, state, navigation, review workflow
  - calls domain services through typed adapters

Platform Bridge
  - iOS PhotoKit access and system deletion prompt
  - Android MediaStore / Photo Picker access and system deletion prompt
  - translates platform asset ids to engine scan items

Core Engine
  - exact content hashes
  - perceptual hashes
  - similarity scoring
  - grouping
  - SQLite-backed cache
```

## Data Flow

```text
Photo Library
  -> Platform Enumerator
  -> ScanItem metadata stream
  -> Core Engine hash pipeline
  -> DuplicateGroup / SimilarGroup output
  -> Flutter review state
  -> Platform deletion request
  -> Audit record
```

## Module Boundaries

- `app/` owns user experience, localization, state, and platform-channel calls.
- `core/` owns deterministic detection and grouping behavior.
- `native/` owns OS API details and permission behavior.
- `docs/` records product and safety decisions.

## Localization

The Flutter app supports English, Chinese, and Japanese from the first app
shell. Locale keys live under `app/lib/src/shared/i18n/`, and English is the
fallback language for missing keys or unsupported device locales.

## Engine Contract

The engine should not know about PhotoKit, MediaStore, Flutter widgets, or UI
language. It should accept normalized scan items and return normalized groups.

Initial DTO shape:

```json
{
  "asset_id": "platform-stable-id",
  "path_hint": "optional local path or display name",
  "width": 4032,
  "height": 3024,
  "size_bytes": 3145728,
  "created_at": "2026-05-13T10:30:00Z",
  "media_type": "image"
}
```

## Persistence

Runtime data is stored only in app-private directories assigned by iOS or
Android. The app must not hard-code public folders for internal thumbnails,
database files, or preferences. See `docs/StorageAndPlatform.md` for the
runtime directory policy and platform boundary rules.

Use SQLite in the app layer for persistent scan and review state:

- asset metadata cache
- content hash cache
- perceptual hash cache
- duplicate groups
- ignored groups
- user keep decisions
- cleanup audit records

SQLite belongs under the app-private application support directory. Thumbnail
binaries are derived cache files and belong under the app-private cache
directory, not in SQLite.

The cache is an optimization, not the only source of truth. The photo library is
always rechecked before deletion.

Initial tables:

- `scan_runs`
- `scan_assets`
- `scan_hashes`
- `duplicate_groups`
- `duplicate_group_members`

The storage implementation is in `app/lib/src/shared/storage/`. Core engine
outputs should be converted into these records at the app boundary.

Lightweight user preferences such as language, theme, scan defaults, and review
sorting live in app-scoped preferences behind a repository in
`app/lib/src/shared/settings/`.

## Platform-Specific Code

Flutter owns the typed platform contract in `app/lib/src/shared/platform/`.
Native implementations live under `native/ios/` and `native/android/`, where
they isolate PhotoKit, MediaStore, Photo Picker, thumbnail loading, and
system-confirmed deletion behavior.
