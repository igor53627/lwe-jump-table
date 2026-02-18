---
id: TASK-6
title: Add tolerance cap and configurable parameters to RustyLock
status: Done
assignee:
  - '@claude'
created_date: '2026-02-18 20:03'
updated_date: '2026-02-18 20:17'
labels:
  - security
  - contracts
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
RustyLock has no upper bound on tolerance. As tolerance approaches q/2 (2048), the LWE problem loses cryptographic hardness and becomes trivially guessable. Add a maxTolerance cap and make toleranceMultiplier configurable by the deployer.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add maxTolerance constructor parameter (default q/4 = 1024)
- [x] #2 Cap getTolerance() return value at maxTolerance
- [x] #3 Make toleranceMultiplier a constructor parameter
- [x] #4 Add tests for tolerance capping behavior
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added immutable baseTolerance, toleranceMultiplier, maxTolerance as constructor params. getTolerance() capped at maxTolerance (must be <= q/2).
<!-- SECTION:FINAL_SUMMARY:END -->
