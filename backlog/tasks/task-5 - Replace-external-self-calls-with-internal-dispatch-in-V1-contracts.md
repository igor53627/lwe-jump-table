---
id: TASK-5
title: Replace external self-calls with internal dispatch in V1 contracts
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:03'
updated_date: '2026-02-18 20:16'
labels:
  - gas
  - contracts
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
BlindOptionVault.sol and PackedBlindOptionVault.sol use external self-calls (this.writeConservativeCall() etc.) for dispatch, costing ~600 gas per call. Replace with internal functions matching PackedBlindOptionVaultV2's pattern.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Refactor BlindOptionVault.sol dispatch to internal functions
- [x] #2 Refactor PackedBlindOptionVault.sol dispatch to internal functions
- [x] #3 All tests pass with no gas regressions
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Converted external self-calls to internal dispatch. Gas savings: V1 -2376, PackedV1 -7127.
<!-- SECTION:FINAL_SUMMARY:END -->
