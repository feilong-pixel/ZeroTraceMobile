# Core Engine

This directory contains the planned portable engine for duplicate and similar
image detection.

The first implementation should run against local fixtures and produce JSON
outputs. Mobile photo-library integration should come after this contract is
stable.

The crate exposes a fixture-first grouping entrypoint so early engine tests can
run without Flutter, iOS, Android, or personal photos.

## Responsibilities

- Normalize scan items.
- Compute exact content hashes.
- Compute perceptual hashes.
- Build duplicate and near-duplicate groups.
- Rank keep candidates.
- Persist and reuse scan cache.

## Non-Responsibilities

- Flutter UI state.
- PhotoKit or MediaStore permissions.
- Platform deletion prompts.
- Localization.

## Planned Rust Crate

```text
crates/zerotrace_core/
  Cargo.toml
  src/
    lib.rs
    fixture_scan.rs
    scan_item.rs
    hashing.rs
    grouping.rs
    ranking.rs
    cache.rs
```
