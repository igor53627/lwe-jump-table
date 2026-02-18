---
id: TASK-5
title: Replace external self-calls with internal dispatch in V1 contracts
status: To Do
assignee: []
created_date: '2026-02-18 20:03'
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
- [ ] #1 Refactor BlindOptionVault.sol dispatch to internal functions
- [ ] #2 Refactor PackedBlindOptionVault.sol dispatch to internal functions
- [ ] #3 All tests pass with no gas regressions
<!-- AC:END -->
