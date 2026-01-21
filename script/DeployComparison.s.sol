// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/PackedBlindOptionVault.sol";
import "../src/PackedBlindOptionVaultV2.sol";
import "../src/utils/PackingUtils.sol";
import "../test/utils/LWEUtils.sol";

/**
 * @title DeployComparison
 * @notice Deploy both V1 and V2 to Tenderly for H2H gas comparison.
 * 
 * Run:
 *   forge script script/DeployComparison.s.sol --rpc-url $TENDERLY_RPC --broadcast
 */
contract DeployComparison is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy V1
        PackedBlindOptionVault vaultV1 = new PackedBlindOptionVault();
        console.log("V1 deployed at:", address(vaultV1));

        // Deploy V2
        PackedBlindOptionVaultV2 vaultV2 = new PackedBlindOptionVaultV2();
        console.log("V2 deployed at:", address(vaultV2));

        // Generate test data
        LWEUtils.RNG memory rng = LWEUtils.initRNG(12345);
        uint256[] memory s_unpacked = LWEUtils.generateSecret(rng);
        uint256[] memory s_packed_dyn = PackingUtils.packVector(s_unpacked);

        // Encrypt message for sector 0 (Conservative)
        (uint256[] memory a0, uint256 b0) = LWEUtils.encrypt(s_unpacked, 512, rng);
        uint256[] memory a0_packed = PackingUtils.packVector(a0);

        // Add strategy to V1
        vaultV1.addStrategy(a0_packed, b0);
        console.log("V1 strategy added");

        // Convert to fixed arrays for V2
        uint256[37] memory a0_fixed;
        uint256[37] memory s_packed_fixed;
        for (uint256 i = 0; i < 37; i++) {
            a0_fixed[i] = a0_packed[i];
            s_packed_fixed[i] = s_packed_dyn[i];
        }

        // Add strategy to V2
        vaultV2.addStrategy(a0_fixed, uint16(b0));
        console.log("V2 strategy added");

        // Execute on both for comparison
        console.log("Executing V1...");
        vaultV1.executeStrategy(0, s_packed_dyn);

        console.log("Executing V2...");
        vaultV2.executeStrategy(0, s_packed_fixed);

        vm.stopBroadcast();

        console.log("\n=== COMPARISON COMPLETE ===");
        console.log("Check Tenderly dashboard for gas traces");
    }
}
