---
id: TASK-6
title: Add tolerance cap and configurable parameters to RustyLock
status: To Do
assignee: []
created_date: '2026-02-18 20:03'
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
- [ ] #1 Add maxTolerance constructor parameter (default q/4 = 1024)
- [ ] #2 Cap getTolerance() return value at maxTolerance
- [ ] #3 Make toleranceMultiplier a constructor parameter
- [ ] #4 Add tests for tolerance capping behavior
<!-- AC:END -->
