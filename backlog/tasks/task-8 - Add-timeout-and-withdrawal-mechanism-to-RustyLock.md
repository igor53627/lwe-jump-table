---
id: TASK-8
title: Add timeout and withdrawal mechanism to RustyLock
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:03'
updated_date: '2026-02-18 20:32'
labels:
  - contracts
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RustyLock has no game timeout — if nobody solves the puzzle, ETH is locked forever. Add a timeout after which depositors can withdraw their deposits proportionally, or the deployer can reclaim.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add game expiry timestamp (constructor parameter)
- [x] #2 Add withdraw function for depositors after expiry
- [x] #3 Block new deposits after expiry
- [x] #4 Block solve attempts after expiry
- [x] #5 Tests for timeout lifecycle
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added game expiry with per-depositor withdrawal. Deposits tracked in mapping, withdrawable after expiry if unsolved. Contribute/commit/solve blocked after expiry.
<!-- SECTION:FINAL_SUMMARY:END -->
