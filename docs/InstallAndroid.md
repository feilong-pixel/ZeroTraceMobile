# Install ExtraSync On Android

ExtraSync is distributed as an Android APK for now. It is not on Google Play yet.

## For Users

1. Download the latest `ExtraSync-vX.Y.Z-android.apk` from GitHub Releases.
2. Copy the APK to your Android phone if you downloaded it on a PC.
3. Open the APK on the phone.
4. If Android asks for permission to install unknown apps, allow it for the app
   you used to open the APK, such as Files, Chrome, or your file manager.
5. Install ExtraSync.
6. Open ExtraSync and pair it with ZeroTraceBrowser on the same local Wi-Fi.

Android may warn that the APK was downloaded outside an app store. That warning
is expected for direct APK installs.

## Accepted Android Sync Behavior

The Android phone-to-PC sync flow was accepted on a real Android phone and PC on
2026-05-30.

Accepted behavior:

- Pair with ZeroTraceBrowser by QR payload.
- Send one manifest batch and upload requested photos.
- Run Auto Sync continuously.
- Use 10-item manifest batches.
- Finish the current 10-item batch before stopping Auto Sync.
- Skip locally persisted terminal items on later runs.
- Produce uploaded PC-side image files that are readable and usable.
- Show credible sync totals for the tested run.

See also:

- [Android Sync Acceptance](AndroidSyncAcceptance.md)
- [v0.2.0 Release Notes](ReleaseNotes-v0.2.0.md)

## For Maintainers

Release APKs must be signed with a stable release keystore. Do not commit the
keystore or passwords.

Create a keystore once:

```powershell
keytool -genkeypair `
  -v `
  -keystore app\extrasync-release.keystore `
  -alias extrasync `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

Copy the template:

```powershell
Copy-Item app\android\key.properties.example app\android\key.properties
```

Edit `app/android/key.properties`:

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=extrasync
storeFile=../extrasync-release.keystore
```

Build the APK:

```powershell
D:\tools\FlutterSdk\flutter\bin\flutter.bat build apk --release
```

Copy the release artifact to `dist/`:

```powershell
New-Item -ItemType Directory -Force dist
Copy-Item app\build\app\outputs\flutter-apk\app-release.apk dist\ExtraSync-v0.2.0-android.apk
Get-FileHash -Algorithm SHA256 dist\ExtraSync-v0.2.0-android.apk
```

Upload the APK and checksum to GitHub Releases.

Keep the same keystore forever for this app. If the keystore is lost, Android
users cannot upgrade over the previous APK and must uninstall first.
