---
id: TASK-3
title: Optimize RustyLock storage access with packed arrays
status: To Do
assignee: []
created_date: '2026-02-18 20:02'
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
- [ ] #1 Change puzzle.a storage from uint256[] to uint256[37] packed
- [ ] #2 Update inner product computation to use SWAR unpacking from storage
- [ ] #3 Update puzzle creation to pack vectors on addPuzzle
- [ ] #4 All existing tests pass
<!-- AC:END -->
