// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PackedBlindOptionVault.sol";
import {LWEPacking} from "evm-lwe-math/src/LWEPacking.sol";
import "./utils/LWEUtils.sol";

contract PackedBlindOptionVaultTest is Test {
    PackedBlindOptionVault public vault;
    using LWEUtils for LWEUtils.RNG;

    uint256[] s_unpacked;
    uint256[] s_packed;

    function setUp() public {
        vault = new PackedBlindOptionVault();
        LWEUtils.RNG memory rng = LWEUtils.initRNG(12345);

        // 1. Generate Secret 's'
        s_unpacked = LWEUtils.generateSecret(rng);
        s_packed = LWEPacking.packVector12(s_unpacked);

        // 2. Generate Strategies (Unpacked first, then pack)
        
        // Strategy 0: Conservative (512)
        (uint256[] memory a0, uint256 b0) = LWEUtils.encrypt(s_unpacked, 512, rng);
        vault.addStrategy(LWEPacking.packVector12(a0), b0);

        // Strategy 1: Aggressive (1536)
        (uint256[] memory a1, uint256 b1) = LWEUtils.encrypt(s_unpacked, 1536, rng);
        vault.addStrategy(LWEPacking.packVector12(a1), b1);
        
        // Strategy 2: Hedge (2560)
        (uint256[] memory a2, uint256 b2) = LWEUtils.encrypt(s_unpacked, 2560, rng);
        vault.addStrategy(LWEPacking.packVector12(a2), b2);
    }

    function test_Packed_EndToEnd_StrategyExecution() public {
        // Execute Strategy 0
        vm.expectEmit(false, false, false, true);
        emit PackedBlindOptionVault.StrategyExecuted(0, "Conservative");
        vault.executeStrategy(0, s_packed);

        // Execute Strategy 1
        vm.expectEmit(false, false, false, true);
        emit PackedBlindOptionVault.StrategyExecuted(0, "Aggressive");
        vault.executeStrategy(1, s_packed);
        
        // Execute Strategy 2
        vm.expectEmit(false, false, false, true);
        emit PackedBlindOptionVault.StrategyExecuted(0, "Hedge");
        vault.executeStrategy(2, s_packed);
    }
}
