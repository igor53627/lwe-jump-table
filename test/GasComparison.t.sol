// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PackedBlindOptionVault.sol";
import "../src/PackedBlindOptionVaultV2.sol";
import "../src/utils/PackingUtils.sol";
import "./utils/LWEUtils.sol";

/**
 * @title GasComparisonTest
 * @notice Head-to-head gas comparison between V1 and V2 implementations.
 */
contract GasComparisonTest is Test {
    PackedBlindOptionVault public vaultV1;
    PackedBlindOptionVaultV2 public vaultV2;
    
    using LWEUtils for LWEUtils.RNG;

    uint256[] s_unpacked;
    uint256[] s_packed_dynamic;
    uint256[37] s_packed_fixed;

    function setUp() public {
        vaultV1 = new PackedBlindOptionVault();
        vaultV2 = new PackedBlindOptionVaultV2();
        
        LWEUtils.RNG memory rng = LWEUtils.initRNG(12345);

        // Generate Secret 's'
        s_unpacked = LWEUtils.generateSecret(rng);
        s_packed_dynamic = PackingUtils.packVector(s_unpacked);
        
        // Copy to fixed array
        for (uint256 i = 0; i < 37; i++) {
            s_packed_fixed[i] = s_packed_dynamic[i];
        }

        // Strategy: Conservative (512)
        (uint256[] memory a0, uint256 b0) = LWEUtils.encrypt(s_unpacked, 512, rng);
        uint256[] memory a0_packed = PackingUtils.packVector(a0);
        
        // Add to V1
        vaultV1.addStrategy(a0_packed, b0);
        
        // Add to V2 (fixed array)
        uint256[37] memory a0_fixed;
        for (uint256 i = 0; i < 37; i++) {
            a0_fixed[i] = a0_packed[i];
        }
        vaultV2.addStrategy(a0_fixed, uint16(b0));
    }

    function test_V1_executeStrategy_Gas() public {
        // Warmup read
        vaultV1.executeStrategy(0, s_packed_dynamic);
        
        // Measure
        uint256 gasBefore = gasleft();
        vaultV1.executeStrategy(0, s_packed_dynamic);
        uint256 gasAfter = gasleft();
        
        uint256 gasUsed = gasBefore - gasAfter;
        emit log_named_uint("V1 executeStrategy gas", gasUsed);
    }

    function test_V2_executeStrategy_Gas() public {
        // Warmup read
        vaultV2.executeStrategy(0, s_packed_fixed);
        
        // Measure
        uint256 gasBefore = gasleft();
        vaultV2.executeStrategy(0, s_packed_fixed);
        uint256 gasAfter = gasleft();
        
        uint256 gasUsed = gasBefore - gasAfter;
        emit log_named_uint("V2 executeStrategy gas", gasUsed);
    }

    function test_V1_Correctness() public {
        vm.expectEmit(false, false, false, true);
        emit PackedBlindOptionVault.StrategyExecuted(0, "Conservative");
        vaultV1.executeStrategy(0, s_packed_dynamic);
    }

    function test_V2_Correctness() public {
        vm.expectEmit(false, false, false, true);
        emit PackedBlindOptionVaultV2.StrategyExecuted(0, "Conservative");
        vaultV2.executeStrategy(0, s_packed_fixed);
    }
}
