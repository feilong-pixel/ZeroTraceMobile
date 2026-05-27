# Product Design

ExtraSync is a focused phone companion for ZeroTraceBrowser. The first
shipping version uploads original phone photos to a paired PC over local Wi-Fi.

## Purpose

- Help the user move phone photos into a ZeroTraceBrowser-managed workspace.
- Keep import policy, hashing, duplicate checks, and organization on the PC.
- Keep the phone UI small enough to trust during repeated sync runs.

## Current Features

- Pair with ZeroTraceBrowser by scanning or pasting a QR payload.
- Save one paired desktop target.
- Send photo metadata manifest batches from the Android media library.
- Upload only the original photos requested by the PC.
- Run continuous automatic sync and stop it from the phone.
- Show progress, current upload, totals, resume policy, and recent failures.

## Explicit Non-Goals

- No on-device duplicate scan in the current mobile app.
- No on-device similar-photo detection in the current mobile app.
- No cleanup review workflow on the phone.
- No phone-side photo deletion or reorganization.
- No cloud upload path.

## Future Placeholder

Similar Photos remains visible as a disabled entry so the product direction is
clear, but it should not be wired until the upload path is stable and the PC-side
import workflow has enough real data.

## First Screen

The dashboard should make the current job obvious:

- short upload-focused description
- primary Phone Sync action
- disabled Similar Photos placeholder
- settings access

The dashboard should not show scan counts, duplicate counts, cleanup estimates,
or review actions.
