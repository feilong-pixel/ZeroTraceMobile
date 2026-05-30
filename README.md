# ExtraSync - Android Photo Transfer to PC over Local Wi-Fi

[中文](README_zh.md) | [日本語](README_ja.md)

ExtraSync is a free, local-first Android photo transfer app for sending original
phone photos to a Windows PC over local Wi-Fi. It works with ZeroTraceBrowser,
so you can back up Android photos to your computer without cloud storage,
subscriptions, or USB cables.

The phone app sends photo metadata first, then uploads only the original files
requested by the desktop side. ZeroTraceBrowser owns the destination root, import
state, hashing, duplicate checks, and final organization.

## Why This Exists

Many people just need a reliable way to move phone photos to a computer without
cloud storage, subscriptions, or cable juggling. ExtraSync is built for that
small but important job: pair the phone with a PC on the same Wi-Fi, then send
the photos the desktop asks for.

It is free, local-first, and intentionally narrow in scope.

ExtraSync is useful if you are looking for an Android photo transfer tool, a
local Wi-Fi photo backup app, or a no-cloud way to move phone photos to a
Windows PC.

## Related Project

ExtraSync is designed to work with ZeroTraceBrowser, the desktop photo organizer
and local gallery manager.

- Project: [ZeroTraceBrowser](https://github.com/feilong-pixel/ZeroTraceBrowser)
- Clone: `git clone https://github.com/feilong-pixel/ZeroTraceBrowser.git`

ZeroTraceBrowser owns the desktop-side destination folder, duplicate checks,
import history, and final photo organization. ExtraSync focuses on the
phone-side upload flow.

## Download / Install

ExtraSync is distributed as an Android APK.

Latest release: [ExtraSync v0.2.0](https://github.com/feilong-pixel/ZeroTraceMobile/releases/tag/v0.2.0)

Android phone-to-PC sync has been accepted on a real Android phone and PC. The
accepted flow includes QR pairing, single-batch transfer, Auto Sync transfer,
background transfer with a foreground-service notification, Wi-Fi-only upload,
gentle transfer pacing, 10-item manifest batches, readable uploaded images on
the PC, and credible sync totals. See [Android Sync Acceptance](docs/AndroidSyncAcceptance.md).

1. Download `ExtraSync-v0.2.0-android.apk` from the release page.
2. Install it on your Android phone.
3. Pair it with ZeroTraceBrowser on the same local Wi-Fi.

See [Install ExtraSync On Android](docs/InstallAndroid.md) for user install
steps and maintainer release-signing instructions.

Useful search terms:

- Android photo transfer to PC over Wi-Fi
- local Wi-Fi photo sync
- free phone photo backup to computer
- no-cloud photo transfer
- Android to Windows photo transfer
- Android photo backup to Windows
- ZeroTraceBrowser mobile sync

## Current Scope

- Pair with ZeroTraceBrowser by scanning or pasting a desktop pairing QR payload.
- Send manifest batches from the Android media library.
- Upload requested original photos to the paired PC.
- Run automatic continuous sync and stop it safely.
- Continue active Auto Sync while the app is backgrounded or the screen is
  locked.
- Upload photos only while the phone is on Wi-Fi.
- Use a user-selected gentle transfer level to pace uploads.
- Resume by skipping locally persisted terminal items for the same
  `server_id + root_id + device_id + item_id`.
- Keep a disabled Similar Photos entry as a future feature placeholder.

Features such as on-device duplicate scanning, cleanup review, and deletion are
not part of the current mobile app scope.

## Project Layout

```text
app/                         Flutter Android application
  lib/
    main.dart                 App entrypoint
    src/
      app/                    App composition, routing, theme
      features/
        dashboard/            Upload-focused home screen
        sync/                 Pairing, manifest, upload, auto-sync UI
        settings/             Pairing and scope copy
      shared/                 I18n, settings, storage, platform adapters

core/                        Reserved for future portable logic
docs/                        Product, architecture, safety notes
```

The active platform implementation is Android. A small iPhone photo-library
interface stub is kept so PhotoKit support can be added later without reshaping
the sync feature.

## Android First

This repository currently ships the Android path. Web, Windows, iOS, and generic
native placeholder directories are intentionally excluded from the active app
tree so the project stays easy to understand and maintain.

## Safety Model

- Photos are sent only to the paired PC on the local network.
- The phone does not delete or reorganize photos.
- Sync can be stopped from the phone UI.
- Imported, duplicate, and locally-deleted states reported by the desktop side
  are skipped on later sync runs.
