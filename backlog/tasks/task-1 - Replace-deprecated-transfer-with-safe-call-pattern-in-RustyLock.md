---
id: TASK-1
title: Replace deprecated transfer() with safe call pattern in RustyLock
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:02'
updated_date: '2026-02-18 20:15'
labels:
  - security
  - contracts
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RustyLock.sol line 139 uses payable(msg.sender).transfer(prize) which has a fixed 2300 gas stipend and can fail with smart contract recipients. Replace with low-level .call{} pattern.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Replace transfer() with (bool success,) = payable(msg.sender).call{value: prize}("") plus require
- [x] #2 Verify RustyLock tests still pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced deprecated transfer() with .call{} pattern. Emit moved before external call (CEI pattern).
<!-- SECTION:FINAL_SUMMARY:END -->
