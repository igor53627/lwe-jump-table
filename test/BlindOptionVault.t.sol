// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/BlindOptionVault.sol";
import "./utils/LWEUtils.sol";

contract BlindOptionVaultTest is Test {
    BlindOptionVault public vault;
    using LWEUtils for LWEUtils.RNG;

    // Constants
    uint256 constant q = 4096;
    
    // Test Data
    uint256[] s;

    function setUp() public {
        vault = new BlindOptionVault();
        LWEUtils.RNG memory rng = LWEUtils.initRNG(12345); // Fixed seed for reproducibility

        // 1. Generate Secret Witness 's'
        s = LWEUtils.generateSecret(rng);

        // 2. Generate and Register Strategies
        // Sectors:
        // Sector 0 (Conservative): Center = q/8  = 512
        // Sector 1 (Aggressive):   Center = 3q/8 = 1536
        // Sector 2 (Hedge):        Center = 5q/8 = 2560
        
        // Strategy 0: Conservative
        (uint256[] memory a0, uint256 b0) = LWEUtils.encrypt(s, 512, rng);
        vault.addStrategy(a0, b0);

        // Strategy 1: Aggressive
        (uint256[] memory a1, uint256 b1) = LWEUtils.encrypt(s, 1536, rng);
        vault.addStrategy(a1, b1);

        // Strategy 2: Hedge
        (uint256[] memory a2, uint256 b2) = LWEUtils.encrypt(s, 2560, rng);
        vault.addStrategy(a2, b2);
    }

    function test_EndToEnd_StrategyExecution() public {
        // Test 1: Execute Strategy 0 (Conservative)
        // We pass the secret 's'. The contract decrypts it to ~512 (Sector 0).
        vm.expectEmit(false, false, false, true);
        emit BlindOptionVault.StrategyExecuted(0, "Conservative");
        vault.executeStrategy(0, s);

        // Test 2: Execute Strategy 1 (Aggressive)
        // We pass the same 's'. The contract decrypts it to ~1536 (Sector 1).
        vm.expectEmit(false, false, false, true);
        emit BlindOptionVault.StrategyExecuted(0, "Aggressive");
        vault.executeStrategy(1, s);

        // Test 3: Execute Strategy 2 (Hedge)
        // We pass the same 's'. The contract decrypts it to ~2560 (Sector 2).
        vm.expectEmit(false, false, false, true);
        emit BlindOptionVault.StrategyExecuted(0, "Hedge");
        vault.executeStrategy(2, s);
    }
}