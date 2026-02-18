---
id: TASK-4
title: Remove debug events from V1 contracts
status: To Do
assignee: []
created_date: '2026-02-18 20:02'
labels:
  - cleanup
  - contracts
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
BlindOptionVault.sol (line 114) and PackedBlindOptionVault.sol (line 186) emit Debug events with placeholder values. These are development artifacts that should be removed for production cleanliness.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Remove Debug event definition and emit from BlindOptionVault.sol
- [ ] #2 Remove Debug event definition and emit from PackedBlindOptionVault.sol
- [ ] #3 All tests pass
<!-- AC:END -->
