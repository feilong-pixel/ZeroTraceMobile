# Product Design

## Positioning

ZeroTraceMobile is a practical photo cleanup app for iPhone and Android. It
focuses on duplicate photos, near-duplicate images, and safe manual review.

The app should feel calm, precise, and trustworthy. It should not ask users to
create an account before scanning local photos, and it should not make deletion
feel automatic or irreversible.

## Core Users

- People with large camera rolls.
- Users who receive the same image from multiple chat apps.
- Users who take burst shots or repeated screenshots.
- Users who want to reclaim storage without sending photos to a server.

## MVP Scope

- Request photo-library access.
- Scan selected or full-library photo assets.
- Detect exact duplicates.
- Detect near-duplicates with perceptual hashes.
- Group results by confidence.
- Recommend one photo to keep per group.
- Let users adjust selections manually.
- Delete through platform-provided confirmation.
- Persist ignored groups and keep decisions.

## Out Of Scope For MVP

- Cloud sync.
- Login accounts.
- AI enhancement or photo editing.
- Background automatic deletion.
- Cross-device cleanup history.
- Heavy semantic similarity models.

## Primary Screens

- Dashboard: scan status, duplicate counts, storage estimate, start/resume scan.
- Scan Progress: current phase, processed count, battery/storage caution.
- Duplicate Groups: exact duplicate and near-duplicate group list.
- Group Review: side-by-side images, metadata, keep recommendation.
- Cleanup Review: final selected count, size estimate, platform deletion prompt.
- Settings: privacy, scan cache, keep preference, confidence thresholds.

## Keep Recommendation Rules

Default ranking:

1. User-pinned keep decision.
2. Higher resolution.
3. Better file quality signal.
4. Earlier original capture time.
5. Non-screenshot source.
6. Larger file size when resolution is equal.

The recommendation must be visible but reversible.
