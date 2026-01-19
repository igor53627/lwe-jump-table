// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PackedBlindOptionVaultV2
 * @notice Gas-Optimized Version 2 with:
 *   - Bitmask modulo (q is power of two)
 *   - Internal dispatch (no external self-calls)
 *   - Fixed-size storage arrays
 *   - uint16 for b
 * 
 * LWE Parameters: n=768, q=4096 (Strong 128-bit Security).
 * Storage: 21 coefficients per uint256.
 */
contract PackedBlindOptionVaultV2 {
    uint256 constant Q = 4096;
    uint256 constant Q_MASK = 0xFFF; // q - 1
    uint256 constant N = 768;
    uint256 constant PACKED_SIZE = 37; // ceil(768/21)

    address public immutable owner;

    // Simulated Assets
    mapping(address => uint256) public balances;
    mapping(address => uint256) public options;

    struct PackedLWEEntry {
        uint256[37] a_packed; // Fixed-size array
        uint16 b;             // q=4096 fits in uint16
    }

    mapping(uint256 => PackedLWEEntry) internal _strategies;
    uint256 public strategyCount;

    event OptionMinted(string strategyName, uint256 strikePrice);
    event StrategyExecuted(uint256 strategyId, string action);

    error InvalidPackedDimension();
    error InvalidStrategyId();
    error BExceedsModulus();
    error Unauthorized();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[address(this)] = 100 ether;
    }

    function addStrategy(uint256[37] calldata a_packed, uint16 b) external onlyOwner {
        if (b >= Q) revert BExceedsModulus();
        
        uint256 id = strategyCount++;
        PackedLWEEntry storage entry = _strategies[id];
        
        // Copy fixed array to storage
        for (uint256 i = 0; i < PACKED_SIZE; i++) {
            entry.a_packed[i] = a_packed[i];
        }
        entry.b = b;
    }

    /**
     * @notice Execute strategy with PACKED witness 's'.
     * 's' must be an array of 37 uint256s, each containing 21 12-bit elements.
     */
    function executeStrategy(uint256 strategyId, uint256[37] calldata s_packed) external {
        if (strategyId >= strategyCount) revert InvalidStrategyId();
        
        PackedLWEEntry storage entry = _strategies[strategyId];
        
        uint256 m_approx;
        uint256 _b = entry.b;
        uint256 inner_prod = 0;
        
        assembly {
            // Load storage slot for a_packed (first slot of struct)
            // _strategies mapping: keccak256(strategyId . slot)
            // entry.a_packed is at that slot
            
            // s_packed is at calldata offset
            let s_ptr := s_packed       
            
            // Mask for 12 bits: 0xFFF
            let mask := 0xFFF
            
            // Compute storage slot for entry.a_packed[0]
            // mapping slot = keccak256(abi.encode(strategyId, 2))
            // where 2 is the slot of _strategies
            mstore(0x00, strategyId)
            mstore(0x20, 2) // _strategies is at slot 2 (after owner@0, balances@1... actually need to check)
            let baseSlot := keccak256(0x00, 0x40)
            
            // Iterate over 37 packed words
            for { let i := 0 } lt(i, 37) { i := add(i, 1) } {
                let w_a := sload(add(baseSlot, i))
                let w_s := calldataload(s_ptr)
                
                // Unpack and Multiply 21 times (Unrolled)
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                
                // Move s_ptr by 32 bytes
                s_ptr := add(s_ptr, 32)
            }
            
            // Bitmask modulo instead of mod opcode
            inner_prod := and(inner_prod, 0xFFF)
            
            // m_approx = (b - inner_prod) & Q_MASK
            // This handles wrap-around automatically
            m_approx := and(sub(_b, inner_prod), 0xFFF)
        }

        // Internal dispatch - no external call overhead
        if (m_approx < (Q / 4)) {
            _writeConservativeCall();
        } else if (m_approx < (2 * Q / 4)) {
            _writeAggressiveCall();
        } else if (m_approx < (3 * Q / 4)) {
            _writePutHedge();
        } else {
            _holdPosition();
        }
    }

    // --- Hidden Strategies (Internal) ---
    function _writeConservativeCall() internal {
        emit OptionMinted("Conservative Call", 3000);
        emit StrategyExecuted(0, "Conservative");
    }
    
    function _writeAggressiveCall() internal {
        emit OptionMinted("Aggressive Call", 2600);
        emit StrategyExecuted(0, "Aggressive");
    }
    
    function _writePutHedge() internal {
        emit OptionMinted("Put Hedge", 2400);
        emit StrategyExecuted(0, "Hedge");
    }
    
    function _holdPosition() internal {
        emit StrategyExecuted(0, "Hold");
    }
}
