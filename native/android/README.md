# Android Bridge

Use MediaStore and the Android Photo Picker where appropriate.

Planned responsibilities:

- request version-appropriate photo permissions
- enumerate image assets through MediaStore
- provide metadata and image bytes to the core engine
- use `MediaStore.createDeleteRequest` on supported Android versions

Deletion must rely on Android system confirmation behavior whenever available.
