# Roadmap

This roadmap keeps the first implementation steps small, testable, and aligned
with the storage, safety, and platform boundaries already documented.

## 1. App Shell

- Build the Flutter app shell, routes, theme, and localization fallback.
- Add empty dashboard, scan, review, duplicates, and settings screens.
- Wire shared service interfaces without real photo-library access.

Exit criteria:

- the app starts on iOS and Android simulators
- English fallback localization works
- navigation reaches each first-milestone screen

## 2. Fixture Scanner

- Keep real device albums out of the first engine milestone.
- Feed synthetic fixture metadata into the core engine.
- Store expected outputs beside fixture sets.

Exit criteria:

- core tests can run without Flutter, iOS, Android, or user photos
- exact duplicate grouping works against fixture metadata
- grouping output uses the same DTO shape expected by the app layer

## 3. Exact Duplicate Detection

- Add content-hash based exact duplicate grouping.
- Persist hash results in the app database once the storage repository exists.
- Keep the photo library as the source of truth before cleanup.

Exit criteria:

- repeat scans reuse cached hash records when valid
- duplicate groups are reproducible from the same fixture input
- review state can survive app restart

## 4. Thumbnail Cache

- Request thumbnails through the platform bridge.
- Cache derived thumbnail files under the app-private cache directory.
- Regenerate thumbnails when cache files are missing.

Exit criteria:

- thumbnails are never stored in SQLite
- thumbnails are never written into the user's photo library
- clearing cache does not lose scan decisions or audit records

## 5. SQLite Persistence

- Add schema and migrations under `app/lib/src/shared/storage/`.
- Store scan runs, scanned assets, hashes, duplicate groups, review decisions,
  and audit records.
- Keep preferences out of the scan database unless they affect persisted review
  state.

Exit criteria:

- app-private database path is used
- migrations are versioned
- scan and review state can be restored after restart

## 6. Native Bridge

- Implement the typed Flutter platform contract for iOS and Android.
- Keep PhotoKit, MediaStore, Photo Picker, and deletion APIs isolated in native
  bridge code.
- Translate platform asset ids into normalized app and engine DTOs.

Exit criteria:

- limited photo access is handled on iOS
- modern Android media permissions are handled
- platform-specific failures are surfaced to Flutter as typed results

## 7. Safe Delete

- Revalidate selected assets before deletion.
- Use the system-confirmed deletion flow on each platform.
- Record accepted, cancelled, skipped, and failed cleanup outcomes.

Exit criteria:

- no hidden deletion path exists
- cancelled deletion leaves review state understandable
- audit records explain what the app requested and what the platform reported
