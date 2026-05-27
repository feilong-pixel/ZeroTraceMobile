# Roadmap

This roadmap keeps ExtraSync focused on phone-to-PC photo upload.

## 1. Android Upload Client

- Pair with ZeroTraceBrowser from QR payload JSON.
- Save the paired desktop target.
- Request Android photo permission.
- Enumerate Android MediaStore image metadata.
- Send manifest batches.
- Upload requested original bytes.
- Store terminal item states so imported, duplicate, and deleted-local items are
  skipped on later runs.

Exit criteria:

- Android phone can pair with a PC on local Wi-Fi.
- Send Manifest Batch uploads requested photos.
- Auto Sync can run continuously and stop from the phone UI.

## 2. Usability Pass

- Show clear sync phase and current upload progress.
- Show automatic sync totals.
- Show recent upload failures.
- Prevent accidental navigation away during active sync.
- Surface common network, token, permission, and read errors in user-facing copy.

Exit criteria:

- The user can understand what the phone is doing during a long sync.
- Failure messages point to a practical next action.

## 3. iPhone Bridge Placeholder

- Keep the `PhotoLibrary` interface platform-neutral.
- Keep an `IosPhotoLibraryChannel` stub in place.
- Implement PhotoKit permission, enumeration, and original-byte access only when
  iPhone support becomes active work.

Exit criteria:

- Android code does not block a later iPhone bridge.
- iPhone code is not exposed as a current feature before implementation.

## 4. Similar Photos Planning

- Keep Similar Photos as a disabled dashboard entry.
- Decide later whether detection belongs on the PC, phone, or shared engine.
- Do not wire phone-side detection until upload/import behavior has real usage
  data.

Exit criteria:

- Placeholder copy is visible.
- No inactive scan, review, or cleanup workflow is reachable in the app.
