// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

library LWEUtils {
    uint256 constant n = 768;
    uint256 constant q = 4096;

    struct LWESample {
        uint256[] a;
        uint256 b;
    }

    // Pseudo-random number generator state
    struct RNG {
        uint256 seed;
    }

    function initRNG(uint256 seed) internal pure returns (RNG memory) {
        return RNG(seed);
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
     * @notice Generates an LWE sample (a, b) encoding a message 'm'
     * b = <a, s> + e + m
     */
    function encrypt(
        uint256[] memory s, 
        uint256 m, 
        RNG memory rng
    ) internal pure returns (uint256[] memory a, uint256 b) {
        a = new uint256[](n);
        uint256 inner_prod = 0;

        // Generate 'a' and compute inner product
        for (uint256 i = 0; i < n; i++) {
            a[i] = next(rng) % q;
            inner_prod += (a[i] * s[i]);
        }
        
        // Generate small noise 'e'.
        // We approximate Gaussian with small uniform noise [-5, 5]
        // mapped to [0, q)
        uint256 rand = next(rng) % 11; // 0..10
        int256 noise = int256(rand) - 5; // -5..5
        
        // b = inner_prod + e + m
        // Handle modular arithmetic with negative noise
        int256 b_int = int256(inner_prod) + noise + int256(m);
        
        // Modulo q
        if (b_int < 0) {
            b = uint256(b_int + int256(q)) % q;
        } else {
            b = uint256(b_int) % q;
        }
    }
}
