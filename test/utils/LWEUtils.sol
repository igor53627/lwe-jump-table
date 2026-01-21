// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {LWEParameters} from "../../src/utils/LWEParameters.sol";

/**
 * @title LWEUtils
 * @notice Test utilities for LWE encryption/decryption.
 * Uses centralized parameters from LWEParameters.
 */
library LWEUtils {
    uint256 constant n = LWEParameters.N;
    uint256 constant q = LWEParameters.Q;
    uint256 constant NOISE_K = LWEParameters.NOISE_K;

    struct LWESample {
        uint256[] a;
        uint256 b;
    }

    struct RNG {
        uint256 seed;
    }

    function initRNG(uint256 seed) internal pure returns (RNG memory) {
        return RNG({seed: seed});
    }

    function next(RNG memory rng) internal pure returns (uint256) {
        rng.seed = uint256(keccak256(abi.encodePacked(rng.seed)));
        return rng.seed;
    }

    /**
     * @notice Generates a random secret vector 's'
     */
    function generateSecret(RNG memory rng) internal pure returns (uint256[] memory s) {
        s = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            s[i] = next(rng) % q;
        }
    }

    /**
     * @notice Sample centered binomial noise with parameter k.
     * Returns value in range [-(k/2), +(k/2)] mapped to [0, q).
     * 
     * Centered binomial: sum of k/2 random bits minus sum of k/2 random bits
     * This approximates Gaussian with sigma = sqrt(k/2)
     * 
     * For k=16: sigma ~ 2.83, range is [-8, +8]
     */
    function sampleCenteredBinomialNoise(RNG memory rng) internal pure returns (int256) {
        uint256 rand = next(rng);
        
        // Count bits in two halves of k bits each
        uint256 halfK = NOISE_K / 2; // 8
        uint256 mask = (1 << halfK) - 1; // 0xFF for k=16
        
        uint256 a = rand & mask;
        uint256 b = (rand >> halfK) & mask;
        
        // Count set bits (popcount)
        uint256 countA = popcount(a);
        uint256 countB = popcount(b);
        
        // Centered binomial: difference of bit counts
        return int256(countA) - int256(countB);
    }
    
    /**
     * @notice Count set bits in a uint256 (up to 8 bits used here)
     */
    function popcount(uint256 x) internal pure returns (uint256 count) {
        while (x != 0) {
            count += x & 1;
            x >>= 1;
        }
    }

    /**
     * @notice Generates an LWE sample (a, b) encoding a message 'm'
     * b = <a, s> + e + m (mod q)
     * 
     * Uses centered binomial noise for improved security.
     */
    function encrypt(
        uint256[] memory s, 
        uint256 m, 
        RNG memory rng
    ) internal pure returns (uint256[] memory a, uint256 b) {
        a = new uint256[](n);
        uint256 innerProd = 0;

        // Generate 'a' and compute inner product
        for (uint256 i = 0; i < n; i++) {
            a[i] = next(rng) % q;
            innerProd += (a[i] * s[i]);
        }
        
        // Sample centered binomial noise
        int256 noise = sampleCenteredBinomialNoise(rng);
        
        // b = innerProd + noise + m (mod q)
        int256 bInt = int256(innerProd % q) + noise + int256(m);
        
        // Handle modular arithmetic
        if (bInt < 0) {
            b = uint256(bInt + int256(q)) % q;
        } else {
            b = uint256(bInt) % q;
        }
    }
    
    /**
     * @notice Decrypt an LWE sample using secret s.
     * Returns m_approx = (b - <a, s>) mod q
     */
    function decrypt(
        uint256[] memory a,
        uint256 b,
        uint256[] memory s
    ) internal pure returns (uint256 mApprox) {
        uint256 innerProd = 0;
        for (uint256 i = 0; i < n; i++) {
            innerProd += (a[i] * s[i]);
        }
        innerProd = innerProd % q;
        
        if (b >= innerProd) {
            mApprox = (b - innerProd) % q;
        } else {
            mApprox = (b + q - innerProd) % q;
        }
    }
}
