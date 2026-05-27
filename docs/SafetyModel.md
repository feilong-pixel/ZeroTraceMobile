# Safety Model

ExtraSync is currently an upload client, not a cleanup tool.

## Guarantees

- No cloud upload path is provided.
- Photos are sent only to the paired ZeroTraceBrowser desktop target.
- The phone app does not delete photos.
- The phone app does not reorganize the Android media library.
- The phone app does not make duplicate or similar-photo decisions locally.
- Sync can be stopped from the phone UI.

## Desktop Authority

ZeroTraceBrowser owns:

- destination root
- import status
- strict duplicate skip decisions
- deleted-local skip decisions
- final file organization

The phone stores only enough terminal item state to avoid repeatedly offering
items the desktop has already resolved.

## Permission Scope

Android photo permission is requested only when sync needs to enumerate and open
photos for upload. iPhone permission behavior is not implemented yet; the
PhotoKit bridge remains a reserved interface.
