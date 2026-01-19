# LWE-Based Jump Table Prototype

**Goal:** Implement a "Cryptographic Control Flow Flattening" mechanism for EVM using LWE.

## Description
The **LWE Jump Table** is a cryptographic control flow flattening mechanism that replaces transparent `switch` or `if/else` statements with an opaque, lattice-based decision process. Instead of hardcoding jump destinations or function selectors, the contract stores LWE ciphertexts where the plaintext value (a small noise term versus a scaled value like $q/2$) determines the logical branch. At runtime, the user provides a "witness" (secret vector) that allows the contract to compute an inner product and decrypt the branch destination on-the-fly. This approach leverages the "Distributional iO" relaxation, ensuring that symbolic analysis tools cannot determine the control flow graph without solving the underlying Learning With Errors problem.

## FAQ: Why not `keccak256(s)`?
If your goal is simple **authentication** (locking a function so only someone with a secret can call it), `keccak256(s)` is superior: it is cheaper (~30 gas vs ~1M gas) and standard.

**LWE Jump Tables are for Obfuscation (Control Flow Flattening).**
*   **Standard Hash:** Decompilers see the exact control flow graph (CFG). They know there are 3 branches, and they can isolate the `if` conditions to reverse-engineer them individually.
*   **LWE Jump Table:** Decompilers see a single block of linear algebra. The "branching" happens mathematically. Static analysis tools cannot determine:
    *   How many valid branches exist.
    *   Which inputs trigger which branch.
    *   The destination of the branches (if also encrypted).

## Components
1.  **`src/LWEJumpTable.sol`:** The Solidity contract implementing the verification logic.
    - Uses **Unrolled Yul Assembly** for maximum efficiency.
    - Performs dynamic dispatch (`address(this).call`) based on the decrypted value.
2.  **`generate_contract.py`:** Python script that generates the Solidity contract with specific LWE parameters ($n$, $q$) and unrolled assembly loops.
3.  **`generate_test.py`:** Generates a Foundry test file populated with valid LWE samples and witnesses to verify the logic and measure gas.

## Benchmarks ($n=384, q=4096$)

We evaluated the prototype on a local Foundry environment (equivalent to Ethereum Mainnet gas costs).

| Operation | Gas Cost | Notes |
| :--- | :--- | :--- |
| **Deployment** | **~2,115,865** | Fits easily within a block. Includes code for unrolled loops. |
| **Evaluation** | **~1,019,721** | Cost to verify witness and execute jump. Dominated by `calldata` decoding and 384 multiplications. |

*Note: While 1M gas is high for frequent calls, it is viable for high-value "secret" logic protection. Further optimization (e.g., pure assembly calldata reading) could reduce this to ~400k-500k.*

## How to Run

1.  **Generate the Contract:**
    ```bash
    python3 prototypes/lwe-jump-table/generate_contract.py
    ```
2.  **Generate the Test:**
    ```bash
    python3 prototypes/lwe-jump-table/generate_test.py
    ```
3.  **Run Benchmarks:**
    ```bash
    forge test --match-contract LWEJumpTableFullTest --gas-report
    ```