# LWE Jump Table Kanban Board

## To Do

### 1. Security Hardening
- [ ] **Increase noise distribution** - Replace `[-5,5]` uniform with centered binomial (k=16+) in LWEUtils
- [ ] **Run lattice estimator** - Document actual security level for (n=768, q=4096, sigma)
- [ ] **Centralize parameters** - Create `Parameters.sol` with Q, N, PACKED_SIZE, MASK constants
- [ ] **Fix parameter mismatch** - BlindOptionVault uses n=384 but LWEUtils uses n=768
- [ ] **Add input validation** - Validate `b < q`, packed word bounds, `strategyId < strategyCount`
- [ ] **Add access control** - Restrict `addStrategy` to owner/allowlist

### 2. Gas Optimization (Tenderly H2H)
- [ ] **Bitmask modulo** - Replace `mod 4096` with `& 0xFFF` (q is power of two)
- [ ] **Internal dispatch** - Replace `this.writeConservativeCall()` with internal functions
- [ ] **Fixed-size storage** - Use `uint256[37]` instead of dynamic arrays
- [ ] **Smaller types** - Use `uint16` for `b` since q=4096 fits
- [ ] **Benchmark on Tenderly** - Compare gas before/after for each optimization

### 3. Code Quality
- [ ] **Extract LWE library** - Deduplicate packed/unpacked eval logic
- [ ] **Fix RustyLock payout** - Replace `transfer` with `call{value:}`
- [ ] **Fix Debug event** - Currently emits `inner=0` always in BlindOptionVault
- [ ] **Remove/gate Debug events** - Production builds shouldn't emit debug info

### 4. Advanced Feature: "Hidden State Machine"
**Goal:** Enable encrypted state transitions (Private Finite State Automata).
- [ ] **Define Architecture:** Design how "Encrypted State" is stored (e.g., recursive LWE ciphertexts)
- [ ] **Implement `SecretQuest.sol`:** Contract where users submit witness sequences to progress through hidden states
- [ ] **Homomorphic Addition:** Implement `add(ciphertext, ciphertext)` in Solidity for state accumulation

## In Progress
*None*

## Done
- [x] **Security:** Parameter Hardening (Upgraded to n=768, q=4096)
- [x] **Gas Optimization:** "Packed" LWE (Reduced gas from ~1.3M to ~110k)
- [x] **Core Primitive:** `BlindOptionVault` (Hidden Strategy Dispatch)
- [x] **Gamification:** `RustyLock` (Lattice Mining Game)
- [x] **Refactoring:** Removed Python dependencies; 100% Solidity/Yul codebase
- [x] **Bug Fix:** Fixed `calldata` pointer arithmetic in `executeStrategy`
