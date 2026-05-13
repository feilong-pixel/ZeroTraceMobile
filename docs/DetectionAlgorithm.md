# Detection Algorithm

## Detection Levels

### 1. Exact Duplicate

Use a content hash such as BLAKE3 or SHA-256. This catches byte-identical files
and has the lowest false-positive risk.

Output confidence: `exact`.

### 2. Near Duplicate

Use perceptual hashes such as dHash and pHash. Compare Hamming distance and group
photos below configured thresholds.

Suggested defaults:

```text
distance <= 5    high confidence
distance <= 10   near duplicate
distance <= 16   similar candidate
```

Output confidence: `high`, `medium`, or `candidate`.

### 3. Semantic Similarity

Keep this out of the MVP. If needed later, use a mobile-friendly embedding model
through Core ML, TensorFlow Lite, or ONNX Runtime Mobile.

## Pipeline

```text
Enumerate assets
  -> normalize metadata
  -> reuse cached hashes when asset fingerprint is unchanged
  -> compute exact hash
  -> compute perceptual hash
  -> build exact groups
  -> build near-duplicate groups
  -> rank keep candidates
  -> emit review-ready groups
```

## Asset Fingerprint

A cached hash can be reused when these fields match:

- platform asset id
- size bytes
- width
- height
- modified timestamp, when available

## False Positive Policy

- Exact duplicate groups may be preselected except the recommended keep item.
- Near-duplicate groups require visible review.
- Candidate groups should never be selected for deletion by default.
