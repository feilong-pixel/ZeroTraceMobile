# Roadmap

This roadmap keeps ExtraSync focused on phone-to-PC photo upload.

## 1. Android Upload Client

Status: accepted on 2026-05-30.

- Pair with ZeroTraceBrowser from QR payload JSON.
- Save the paired desktop target.
- Request Android photo permission.
- Enumerate Android MediaStore image metadata.
- Send manifest batches.
- Upload requested original bytes.
- Store terminal item states so imported, duplicate, and deleted-local items are
  skipped on later runs.

Exit criteria:

- Android phone can pair with a PC on local Wi-Fi. Passed.
- Send Manifest Batch uploads requested photos. Passed.
- Auto Sync can run continuously and stop from the phone UI. Passed for the
  tested run.
- Stop during Auto Sync finishes the current 10-item batch before stopping.
  Accepted as current behavior.
- Uploaded images on the PC are valid and readable. Passed.
- Sync totals are credible for the tested run. Passed.

Acceptance record:

- `docs/AndroidSyncAcceptance.md`

## 2. Usability Pass

Status: core sync-status visualization implemented for the current Android
scope. Future work should stay limited to copy polish or regression fixes.

- Show clear sync phase and current upload progress.
- Show automatic sync totals.
- Show recent upload failures.
- Prevent accidental navigation away during active sync.
- Surface common network, token, permission, and read errors in user-facing copy.
- Keep sync history, item management, duplicate review, deleted-local review,
  and reset workflows on the PC side.

Exit criteria:

- The user can understand what the phone is doing during a long sync. Passed
  for the current Android scope.
- Failure messages point to a practical next action.
- The phone remains a light client and does not become the sync management
  console.

## 2.5 Android Background Transfer

Status: accepted on 2026-05-30.

- Keep Auto Sync user-visible while upload is active.
- Start an Android foreground service when Auto Sync starts.
- Stop the foreground service when Auto Sync exits or is stopped.
- Keep batching and upload orchestration in the existing Flutter sync loop.
- Do not introduce silent killed-process recovery in this step.

Exit criteria:

- Auto Sync shows an Android foreground-service notification while active.
  Passed.
- The transfer can continue more reliably when the app is backgrounded or the
  screen is locked. Passed.
- Stopping Auto Sync removes the foreground-service notification. Passed.
- If the process is killed, reopening the app and starting Auto Sync again
  resumes through existing terminal item state.

## 2.6 Transfer Conditions And Gentle Pace

Status: next implementation candidate.

- Upload photos only while the Android device is on Wi-Fi.
- Pause or stop Auto Sync before additional original-byte uploads if Wi-Fi is
  unavailable.
- Do not automatically resume in the background after Wi-Fi returns; require the
  user to start Auto Sync again.
- Add a Phone Sync page `Gentle Transfer` control with levels 1-5.
- Persist the selected gentle-transfer level locally.
- Apply the selected delay after each uploaded item:

```text
1 = 100 ms
2 = 200 ms
3 = 300 ms
4 = 400 ms
5 = 500 ms
```

- Default to level 3.
- Do not add a fixed 3-second pause after each 10-item batch.
- Do not implement complex phone-idle polling.

Exit criteria:

- Auto Sync refuses or pauses upload when Wi-Fi is unavailable.
- Returning to Wi-Fi requires a manual Auto Sync restart, with terminal item
  state preventing completed items from uploading again.
- The sync page shows the selected gentle-transfer level.
- Upload pacing follows the selected level.
- The app remains understandable: any pause reason is visible to the user.

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
