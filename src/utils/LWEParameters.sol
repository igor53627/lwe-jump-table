// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LWEParameters
 * @notice Centralized LWE parameters for all contracts.
 * 
 * Security Analysis (pending lattice estimator):
 * - n = 768: dimension of secret vector
 * - q = 4096: modulus (power of 2 for efficient arithmetic)
 * - sigma ~ sqrt(k/2) where k=16 for centered binomial noise
 * 
 * Packing: 21 elements per uint256 (12 bits each, 252 bits used)
 * PACKED_SIZE = ceil(768/21) = 37
 */
library LWEParameters {
    uint256 internal constant N = 768;
    uint256 internal constant Q = 4096;
    uint256 internal constant Q_MASK = 0xFFF; // Q - 1
    uint256 internal constant BIT_WIDTH = 12;
    uint256 internal constant ELEMENTS_PER_WORD = 21;
    uint256 internal constant PACKED_SIZE = 37; // ceil(N / ELEMENTS_PER_WORD)
    
    // Noise parameter for centered binomial
    // k=16 gives sigma ~ sqrt(8) ~ 2.83
    // Decoding margin: q/4 = 1024, so |e| < 1024 is safe for 4-sector dispatch
    uint256 internal constant NOISE_K = 16;
    
    // Sector boundaries for 4-way dispatch
    uint256 internal constant SECTOR_0_MAX = Q / 4;      // 1024
    uint256 internal constant SECTOR_1_MAX = Q / 2;      // 2048  
    uint256 internal constant SECTOR_2_MAX = 3 * Q / 4;  // 3072
}
