// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/utils/PackingUtils.sol";
import "./utils/LWEUtils.sol";

contract PackingTest is Test {
    using LWEUtils for LWEUtils.RNG;

    function test_PackUnpackRoundtrip() public {
        LWEUtils.RNG memory rng = LWEUtils.initRNG(111);
        
        // 1. Generate random vector 'a' of size 384
        uint256 n = 384;
        uint256[] memory original = new uint256[](n);
        for(uint256 i=0; i<n; i++) {
            original[i] = LWEUtils.next(rng) % 4096;
        }

        // 2. Pack it
        uint256[] memory packed = PackingUtils.packVector(original);
        
        // Verify size
        // 384 / 21 = 18.28 -> 19 words
        assertEq(packed.length, 19);

        // 3. Unpack it (simulating reading from storage and unpacking element by element)
        uint256[] memory unpacked = PackingUtils.unpackVector(packed, n);

        // 4. Compare
        for(uint256 i=0; i<n; i++) {
            assertEq(unpacked[i], original[i], "Mismatch at index");
        }
    }
}
