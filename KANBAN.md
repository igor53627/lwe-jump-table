# LWE Jump Table Kanban Board

## To Do

### 1. Security Hardening
- [x] **Increase noise distribution** - Centered binomial (k=16, sigma~2.83) in LWEUtils
- [x] **Run lattice estimator** - tools/estimate_lwe.py confirms >128-bit security
- [x] **Centralize parameters** - Created `LWEParameters.sol` with Q, N, PACKED_SIZE, MASK
- [x] **Fix parameter mismatch** - BlindOptionVault now uses n=768 from LWEParameters
- [x] **Add input validation** - Validate `b < q`, `strategyId < strategyCount` (in V2)
- [x] **Add access control** - Restrict `addStrategy` to owner (in V2)

### 2. Gas Optimization (Tenderly H2H)
- [x] **Bitmask modulo** - Replace `mod 4096` with `& 0xFFF` (q is power of two)
- [x] **Internal dispatch** - Replace `this.writeConservativeCall()` with internal functions
- [x] **Fixed-size storage** - Use `uint256[37]` instead of dynamic arrays
- [x] **Smaller types** - Use `uint16` for `b` since q=4096 fits
- [ ] **Benchmark on Tenderly** - Deploy V1 vs V2 and compare actual on-chain gas

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
