# ZeroTraceMobile

ZeroTraceMobile is a local-first iPhone and Android app for duplicate photos,
near-duplicate images, and similar-picture review.

The product principle is simple: scan on device, explain every group, let the
user review before deletion, and never upload private photos to a cloud service.

## Project Layout

```text
app/                         Flutter application shell
  lib/
    main.dart                 App entrypoint placeholder
    src/
      app/                    App composition, routing, theme
      features/               User-facing feature modules
      shared/                 Shared UI and platform adapters

core/                        Portable duplicate/similarity engine
  crates/zerotrace_core/      Planned Rust crate for hashing, grouping, cache IO
  fixtures/                   Test image sets and expected scan outputs

native/                      Platform bridge contracts
  ios/                        PhotoKit and deletion bridge notes
  android/                    MediaStore / Photo Picker bridge notes

docs/                        Product, architecture, algorithm, safety notes
```

## First Milestone

1. Build the app shell and navigation in Flutter.
2. Implement a fixture-based scanner in `core/` before touching real albums.
3. Add exact duplicate detection with content hashes.
4. Add perceptual hash grouping for near-duplicates.
5. Connect iOS PhotoKit and Android MediaStore only after the engine contracts are
   stable.

## Safety Model

- All scanning is local by default.
- Deletion always goes through platform confirmation.
- Scan results and ignore/keep decisions stay on device.
- The app records cleanup actions so users can understand what happened later.
