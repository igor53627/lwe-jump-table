---
id: TASK-7
title: Add comprehensive test coverage
status: To Do
assignee: []
created_date: '2026-02-18 20:03'
labels:
  - testing
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Current test suite has 8 tests covering happy paths only. Add edge case and boundary tests for all contracts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 BlindOptionVault: test invalid witness length and invalid strategy ID
- [ ] #2 All vaults: test sector boundary values (m_approx = q/4, q/2, 3q/4 exactly)
- [ ] #3 RustyLock: test tolerance scaling with multiple deposits
- [ ] #4 RustyLock: test failed solutions (error > tolerance)
- [ ] #5 RustyLock: test modular distance edge cases
- [ ] #6 LWEUtils: add dedicated unit tests for generateSecret, encrypt, decrypt, popcount
<!-- AC:END -->
