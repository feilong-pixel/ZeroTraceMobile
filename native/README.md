# Native Bridge

This directory documents and later contains platform-specific bridge code.

The bridge should expose a small typed surface to Flutter:

- request photo access
- enumerate photo assets
- open an image stream or thumbnail stream for hashing/review
- request system-confirmed deletion
- report platform result details

The bridge should not implement grouping or ranking logic.
