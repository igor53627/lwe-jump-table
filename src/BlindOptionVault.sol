// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LWEParameters} from "./utils/LWEParameters.sol";

/**
 * @title BlindOptionVault
 * @notice Encrypted Strategy Execution for an ETH Option Vault.
 * The logic for WHICH option to write is hidden in the LWE ciphertext.
 * 
 * LWE Parameters: n=768, q=4096
 */
contract BlindOptionVault {
    uint256 constant q = LWEParameters.Q;
    uint256 constant n = LWEParameters.N;

    // Simulated Assets
    mapping(address => uint256) public balances; // ETH Balance
    mapping(address => uint256) public options;  // Option Token Balance

    struct LWEEntry {
        uint256[] a;
        uint256 b;
    }

    // Maps EntryID -> LWE Ciphertext
    mapping(uint256 => LWEEntry) public strategies;
    uint256 public strategyCount;

    event OptionMinted(string strategyName, uint256 strikePrice);
    event StrategyExecuted(uint256 strategyId, string action);
    event Debug(uint256 b, uint256 inner, uint256 m_approx);

    constructor() {
        // Seed some initial balance for the vault
        balances[address(this)] = 100 ether;
    }

    function addStrategy(uint256[] memory a, uint256 b) public {
        require(a.length == n, "Invalid dimension");
        uint256 id = strategyCount++;
        strategies[id] = LWEEntry(a, b);
    }

    /**
     * @notice Execute the hidden strategy using a witness 's'.
     * The witness is derived off-chain from market data (IV, Price, etc).
     */
    function executeStrategy(uint256 strategyId, uint256[] calldata s) public {
        require(s.length == n, "Invalid witness dimension");
        
        LWEEntry memory entry = strategies[strategyId];
        
        uint256 m_approx;
        uint256 _q = q;
        uint256 _b = entry.b;
        
        // Compute Inner Product <a, s> mod q
        // Using Yul with 32-step unrolling for n=768 (24 iterations of 32)
        assembly {
            let a_ptr := add(mload(entry), 32) 
            let s_base := s.offset // s.offset points to s[0] in calldata
            let inner_prod := 0
            let i := 0

            // 768 / 32 = 24 iterations
            for {} lt(i, 768) { i := add(i, 32) } {
                // Unroll 32 times
                inner_prod := add(inner_prod, mul(mload(a_ptr), calldataload(s_base)))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 32)), calldataload(add(s_base, 32))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 64)), calldataload(add(s_base, 64))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 96)), calldataload(add(s_base, 96))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 128)), calldataload(add(s_base, 128))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 160)), calldataload(add(s_base, 160))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 192)), calldataload(add(s_base, 192))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 224)), calldataload(add(s_base, 224))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 256)), calldataload(add(s_base, 256))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 288)), calldataload(add(s_base, 288))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 320)), calldataload(add(s_base, 320))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 352)), calldataload(add(s_base, 352))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 384)), calldataload(add(s_base, 384))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 416)), calldataload(add(s_base, 416))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 448)), calldataload(add(s_base, 448))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 480)), calldataload(add(s_base, 480))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 512)), calldataload(add(s_base, 512))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 544)), calldataload(add(s_base, 544))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 576)), calldataload(add(s_base, 576))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 608)), calldataload(add(s_base, 608))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 640)), calldataload(add(s_base, 640))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 672)), calldataload(add(s_base, 672))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 704)), calldataload(add(s_base, 704))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 736)), calldataload(add(s_base, 736))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 768)), calldataload(add(s_base, 768))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 800)), calldataload(add(s_base, 800))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 832)), calldataload(add(s_base, 832))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 864)), calldataload(add(s_base, 864))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 896)), calldataload(add(s_base, 896))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 928)), calldataload(add(s_base, 928))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 960)), calldataload(add(s_base, 960))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 992)), calldataload(add(s_base, 992))))

                // Increment pointers by 32 * 32 bytes = 1024
                a_ptr := add(a_ptr, 1024)
                s_base := add(s_base, 1024)
            }
            
            // Bitmask modulo (q is power of 2)
            inner_prod := and(inner_prod, 0xFFF)
            
            // Decrypt: m_approx = (b - inner_prod) & Q_MASK
            m_approx := and(sub(add(_b, _q), inner_prod), 0xFFF)
        }
        
        emit Debug(_b, 0, m_approx); // Pass 0 for inner_prod as it's local to assembly

        // --- Multi-Way Dispatch Logic ---
        // Sectors: [0, q/4), [q/4, 2q/4), [2q/4, 3q/4), [3q/4, q)
        
        if (m_approx < (q / 4)) {
            this.writeConservativeCall();
        } else if (m_approx < (2 * q / 4)) {
            this.writeAggressiveCall();
        } else if (m_approx < (3 * q / 4)) {
            this.writePutHedge();
        } else {
            this.holdPosition();
        }
    }

    // --- Hidden Strategies ---

    function writeConservativeCall() external {
        emit OptionMinted("Conservative Call", 3000);
        emit StrategyExecuted(0, "Conservative");
    }

    function writeAggressiveCall() external {
        emit OptionMinted("Aggressive Call", 2600);
        emit StrategyExecuted(0, "Aggressive");
    }

    function writePutHedge() external {
        emit OptionMinted("Put Hedge", 2400);
        emit StrategyExecuted(0, "Hedge");
    }

    function holdPosition() external {
        emit StrategyExecuted(0, "Hold");
    }
}
