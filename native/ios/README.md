# iOS Bridge

Use PhotoKit for library access and deletion.

Planned responsibilities:

- request `PHPhotoLibrary` authorization
- support Limited Photos access
- enumerate image assets
- provide metadata and image bytes to the core engine
- call `PHPhotoLibrary.shared().performChanges` for deletion

Deletion must rely on iOS system confirmation behavior.
