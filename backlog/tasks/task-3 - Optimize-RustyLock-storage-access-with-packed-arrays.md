---
id: TASK-3
title: Optimize RustyLock storage access with packed arrays
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:02'
updated_date: '2026-02-18 20:19'
labels:
  - gas
  - contracts
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RustyLock.sol line 76 copies a 768-element dynamic array from storage to memory (~1500+ gas overhead). Refactor to use packed storage (37 fixed-size uint256 words) and direct SLOAD in assembly, matching PackedBlindOptionVaultV2's approach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Change puzzle.a storage from uint256[] to uint256[37] packed
- [x] #2 Update inner product computation to use SWAR unpacking from storage
- [x] #3 Update puzzle creation to pack vectors on addPuzzle
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Converted RustyLock to packed 12-bit storage (37 fixed words) with SWAR inner product. Gas for solve(): 4,139,206 -> 292,159 (93% reduction). Uses direct SLOAD instead of memory copy.
<!-- SECTION:FINAL_SUMMARY:END -->
