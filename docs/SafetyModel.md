# Safety Model

## Principles

- No cloud upload by default.
- No hidden deletion.
- No permanent deletion copy in the app UI unless the platform actually performs
  permanent deletion.
- Every destructive step must be confirmable and explainable.

## Non-Goals and Guardrails

- Do not upload photo contents, thumbnails, hashes, or scan results by default.
- Do not delete files by raw filesystem path.
- Do not bypass iOS or Android system-confirmed deletion prompts.
- Do not write internal thumbnails, logs, or databases into the user's photo
  library.
- Do not store review plans only in memory when they need to survive app
  restart.
- Do not treat cached metadata as proof that an asset still exists before
  deletion.
- Do not mix platform-specific PhotoKit or MediaStore behavior into the core
  detection engine.

## Deletion Flow

```text
User selects items
  -> Cleanup Review screen
  -> App validates assets still exist
  -> Platform deletion API is called
  -> iOS or Android system confirmation appears
  -> App records accepted, cancelled, or failed result
```

## Platform Notes

### iOS

Use PhotoKit. Deletion should go through `PHPhotoLibrary` changes so iOS presents
the appropriate system confirmation.

Limited Photos access must be supported.

### Android

Use MediaStore on modern Android. For Android 11+, deletion should use
`MediaStore.createDeleteRequest` where available so the system owns final user
confirmation.

Android 13+ photo permissions must be handled separately from older storage
permissions.

## Review Defaults

- Exact duplicates: select all except recommended keep.
- Near duplicates: show recommendations but require user review.
- Similar candidates: do not preselect.

## Audit Records

Store local audit entries with:

- operation id
- timestamp
- requested asset ids
- platform result
- count deleted
- count skipped or failed
- failure reasons when available
