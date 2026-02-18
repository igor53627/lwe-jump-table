---
id: TASK-2
title: Add commit-reveal scheme to RustyLock for MEV protection
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:02'
updated_date: '2026-02-18 20:17'
labels:
  - security
  - contracts
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RustyLock solutions are frontrunnable — a solver's secret vector is visible in the mempool. Add a two-phase commit-reveal scheme: (1) commit hash of solution, (2) reveal after N blocks. This prevents MEV searchers from stealing solutions.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add commit phase: user submits hash of (sender, secret_vector)
- [x] #2 Add reveal phase: user reveals secret_vector after commit delay
- [x] #3 Add commit delay constant (e.g. 2 blocks)
- [x] #4 Tests for commit-reveal lifecycle
- [x] #5 Test that direct reveal without commit reverts
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added two-phase commit-reveal to RustyLock. Solvers commit hash(sender, solution), wait 2 blocks, then reveal. Prevents MEV frontrunning of solutions.
<!-- SECTION:FINAL_SUMMARY:END -->
