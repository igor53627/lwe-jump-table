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
        s_secret = LWEUtils.generateSecret(rng);
        (uint256[] memory a, uint256 b) = LWEUtils.encrypt(s_secret, 0, rng);
        // baseTolerance=10, multiplier=1, maxTolerance=1024
        game = new RustyLock(a, b, 10, 1, 1024);
    }

    function test_WinGame() public {
        // 1. Initial tolerance
        assertEq(game.getTolerance(), 10);

        // 2. Contribute to increase tolerance
        game.contribute{value: 10 ether}();
        assertEq(game.getTolerance(), 20); // 10 base + 10 bonus

        // 3. Commit solution hash
        bytes32 commitHash = keccak256(abi.encode(address(this), s_secret));
        game.commit(commitHash);

        // 4. Advance blocks past commit delay
        vm.roll(block.number + 2);

        // 5. Reveal and win
        uint256 preBalance = address(this).balance;
        game.solve(s_secret);
        uint256 postBalance = address(this).balance;

        assertEq(postBalance - preBalance, 10 ether);
        assertTrue(game.solved());
    }

    function test_RevertSolveWithoutCommit() public {
        game.contribute{value: 10 ether}();
        vm.expectRevert("No commit found");
        game.solve(s_secret);
    }

    function test_RevertSolveTooEarly() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_secret));
        game.commit(commitHash);
        // Don't advance blocks
        vm.expectRevert("Reveal too early");
        game.solve(s_secret);
    }

    function test_RevertSolveInvalidReveal() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_secret));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        // Submit wrong solution
        uint256[] memory wrong = new uint256[](768);
        vm.expectRevert("Invalid reveal");
        game.solve(wrong);
    }

    function test_ToleranceCap() public {
        // Deposit enough to exceed maxTolerance (1024)
        game.contribute{value: 2000 ether}();
        // Should be capped at 1024, not 10 + 2000 = 2010
        assertEq(game.getTolerance(), 1024);
    }

    function test_RevertAfterSolved() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_secret));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        game.solve(s_secret);

        // Can't solve again
        vm.expectRevert("Already solved");
        game.commit(commitHash);
    }

    function test_RevertContributeAfterSolved() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_secret));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        game.solve(s_secret);

        vm.expectRevert("Already solved");
        game.contribute{value: 1 ether}();
    }

    receive() external payable {}
}
