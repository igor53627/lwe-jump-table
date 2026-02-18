---
id: TASK-2
title: Add commit-reveal scheme to RustyLock for MEV protection
status: To Do
assignee: []
created_date: '2026-02-18 20:02'
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
- [ ] #1 Add commit phase: user submits hash of (sender, secret_vector)
- [ ] #2 Add reveal phase: user reveals secret_vector after commit delay
- [ ] #3 Add commit delay constant (e.g. 2 blocks)
- [ ] #4 Tests for commit-reveal lifecycle
- [ ] #5 Test that direct reveal without commit reverts
<!-- AC:END -->
