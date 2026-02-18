---
id: TASK-7
title: Add comprehensive test coverage
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:03'
updated_date: '2026-02-18 20:32'
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
- [x] #1 BlindOptionVault: test invalid witness length and invalid strategy ID
- [x] #2 All vaults: test sector boundary values (m_approx = q/4, q/2, 3q/4 exactly)
- [x] #3 RustyLock: test tolerance scaling with multiple deposits
- [x] #4 RustyLock: test failed solutions (error > tolerance)
- [x] #5 RustyLock: test modular distance edge cases
- [x] #6 LWEUtils: add dedicated unit tests for generateSecret, encrypt, decrypt, popcount
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Comprehensive test suite: 28 tests total (was 8). Covers constructor validation (5 boundary tests), commit-reveal lifecycle, post-solve reverts, timeout/withdrawal (6 tests including multi-depositor), transfer failure with reverting recipient, tolerance cap.
<!-- SECTION:FINAL_SUMMARY:END -->
