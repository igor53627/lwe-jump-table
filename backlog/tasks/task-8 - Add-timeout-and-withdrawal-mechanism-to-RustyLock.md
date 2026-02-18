---
id: TASK-8
title: Add timeout and withdrawal mechanism to RustyLock
status: To Do
assignee: []
created_date: '2026-02-18 20:03'
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
- [ ] #1 Add game expiry timestamp (constructor parameter)
- [ ] #2 Add withdraw function for depositors after expiry
- [ ] #3 Block new deposits after expiry
- [ ] #4 Block solve attempts after expiry
- [ ] #5 Tests for timeout lifecycle
<!-- AC:END -->
