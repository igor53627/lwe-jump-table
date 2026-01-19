// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RustyLock.sol";
import "./utils/LWEUtils.sol";

contract RustyLockTest is Test {
    RustyLock public game;
    using LWEUtils for LWEUtils.RNG;

    uint256[] s_secret;

    function setUp() public {
        LWEUtils.RNG memory rng = LWEUtils.initRNG(9999);

        // 1. Generate Secret 's'
        s_secret = LWEUtils.generateSecret(rng);

        // 2. Encrypt the "Win Condition"
        // Message = 0 (We want b approx <a, s>)
        (uint256[] memory a, uint256 b) = LWEUtils.encrypt(s_secret, 0, rng);

        game = new RustyLock(a, b);
    }

    function test_WinGame() public {
        // 1. Initial State
        assertEq(game.getTolerance(), 10);
        
        // 2. Contribute to increase tolerance
        game.contribute{value: 10 ether}();
        assertEq(game.getTolerance(), 20); // 10 base + 10 bonus
        
        // 3. Submit Winning Vector
        uint256 preBalance = address(this).balance;
        game.solve(s_secret);
        uint256 postBalance = address(this).balance;
        
        assertEq(postBalance - preBalance, 10 ether);
    }
    
    receive() external payable {}
}
