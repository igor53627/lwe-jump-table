// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PackedBlindOptionVault
 * @notice Gas-Optimized Version using Packed Storage (SWAR-ish).
 * LWE Parameters: n=768, q=4096 (Strong 128-bit Security).
 * Storage: 21 coefficients per uint256.
 */
contract PackedBlindOptionVault {
    uint256 constant q = 4096;
    uint256 constant n = 768;
    // 21 elements per word. 768 / 21 = 36.57 -> 37 words.
    uint256 constant PACKED_SIZE = 37; 

    // Simulated Assets
    mapping(address => uint256) public balances;
    mapping(address => uint256) public options;

    struct PackedLWEEntry {
        uint256[] a_packed; // length 37
        uint256 b;
    }

    mapping(uint256 => PackedLWEEntry) public strategies;
    uint256 public strategyCount;

    event OptionMinted(string strategyName, uint256 strikePrice);
    event StrategyExecuted(uint256 strategyId, string action);
    constructor() {
        balances[address(this)] = 100 ether;
    }

    function addStrategy(uint256[] memory a_packed, uint256 b) public {
        require(a_packed.length == PACKED_SIZE, "Invalid packed dimension");
        uint256 id = strategyCount++;
        strategies[id] = PackedLWEEntry(a_packed, b);
    }

    /**
     * @notice Execute strategy with PACKED witness 's'.
     * 's' must be an array of 37 uint256s, each containing 21 12-bit elements.
     */
    function executeStrategy(uint256 strategyId, uint256[] calldata s_packed) public {
        require(s_packed.length == PACKED_SIZE, "Invalid witness dimension");
        
        PackedLWEEntry memory entry = strategies[strategyId];
        
        uint256 m_approx;
        uint256 _q = q;
        uint256 _b = entry.b;
        uint256 inner_prod = 0;
        
        assembly {
            // Pointers
            let a_ptr := add(mload(entry), 32) 
            let s_ptr := s_packed.offset       
            
            // Mask for 12 bits: 0xFFF
            let mask := 0xFFF
            
            // Iterate over 37 packed words
            for { let i := 0 } lt(i, 37) { i := add(i, 1) } {
                let w_a := mload(a_ptr)
                let w_s := calldataload(s_ptr)
                
                // Unpack and Multiply 21 times (Unrolled)
                
                // 1
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                // 2
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                // 3
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 4
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 5
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 6
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 7
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 8
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)
                
                // 9
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 10
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 11
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 12
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 13
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 14
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 15
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 16
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 17
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 18
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 19
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 20
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                // 21
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                
                // Move pointers
                a_ptr := add(a_ptr, 32)
                s_ptr := add(s_ptr, 32)
            }
            
            inner_prod := mod(inner_prod, _q)
            
            switch lt(_b, inner_prod)
            case 1 { m_approx := sub(add(_b, _q), inner_prod) }
            default { m_approx := sub(_b, inner_prod) }
        }
        
        if (m_approx < (q / 4)) {
            _writeConservativeCall();
        } else if (m_approx < (2 * q / 4)) {
            _writeAggressiveCall();
        } else if (m_approx < (3 * q / 4)) {
            _writePutHedge();
        } else {
            _holdPosition();
        }
    }

    function _writeConservativeCall() internal { emit OptionMinted("Conservative Call", 3000); emit StrategyExecuted(0, "Conservative"); }
    function _writeAggressiveCall() internal { emit OptionMinted("Aggressive Call", 2600); emit StrategyExecuted(0, "Aggressive"); }
    function _writePutHedge() internal { emit OptionMinted("Put Hedge", 2400); emit StrategyExecuted(0, "Hedge"); }
    function _holdPosition() internal { emit StrategyExecuted(0, "Hold"); }
}