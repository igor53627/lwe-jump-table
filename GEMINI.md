# LWE Jump Table Project

## Project Overview
This project explores **Lattice-Based Cryptography** on the EVM to enable new privacy and gamification primitives.

**Core Tech:** Learning With Errors (LWE) decryption on-chain using optimized Yul assembly.
**Status:** Pure Solidity/Foundry environment (No Python dependencies).

## 1. The "Killer App": Blind Option Vault
A DeFi vault that runs a **proprietary trading strategy** on-chain without revealing it.
*   **Contract:** `src/BlindOptionVault.sol`
*   **Concept:** Encrypts the decision boundaries. The contract computes `Matrix * MarketData` to decide whether to Buy/Sell/Hold.
*   **Why:** Allows funds to prove they are executing a specific strategy without giving away the alpha.

## 2. The Gamified App: "The Rusty Lock"
A **Progressive Lattice Puzzle** (Gambling/Mining Game).
*   **Contract:** `src/RustyLock.sol`
*   **Concept:** A pot of ETH locked by an LWE problem.
*   **Mechanic:** Users deposit ETH to "weaken" the lock (increase noise tolerance).
*   **Winning:** The first person to find a vector `s` close enough to the solution wins the entire pot.
*   **Dynamics:** Creates a race between Capital (depositors) and Compute (lattice reduction solvers).

## Development
*   **Build:** `forge build`
*   **Test:** `forge test`
    *   Tests use `test/utils/LWEUtils.sol` to generate valid LWE ciphertexts and witnesses in pure Solidity.

## Key Files
*   `src/BlindOptionVault.sol` - Hidden Strategy Logic.
*   `src/RustyLock.sol` - Lattice Gambling Game.
*   `test/utils/LWEUtils.sol` - Test utility for on-chain LWE sample generation.

## Technology & Benchmarks
*   **LWE Parameters:** $n=768, q=4096$ (Strong >128-bit Security).
*   **Optimization:** Uses "Packed LWE" (21 coefficients per `uint256` word) and SWAR assembly logic.

| Operation | Gas Cost (Packed) | Notes |
| :--- | :--- | :--- |
| **Deployment** | **~1,166,241** | One-time cost. |
| **Add Strategy** | **~925,468** | Cost to register a new encrypted strategy. |
| **Evaluation** | **~183,646** | **Per-execution cost.** Comparable to a Uniswap swap. |
