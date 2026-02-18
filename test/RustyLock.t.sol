// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RustyLock.sol";
import {LWEPacking} from "evm-lwe-math/src/LWEPacking.sol";
import "./utils/LWEUtils.sol";

/// @dev Recipient that reverts on receive (for testing transfer failure).
contract RevertingRecipient {
    RustyLock public game;

    constructor(RustyLock _game) { game = _game; }

    function commitAndSolve(uint256[37] calldata sPacked) external {
        bytes32 h = keccak256(abi.encode(address(this), sPacked));
        game.commit(h);
    }

    function reveal(uint256[37] calldata sPacked) external {
        game.solve(sPacked);
    }

    // No receive() — will revert on ETH transfer
}

contract RustyLockTest is Test {
    RustyLock public game;
    using LWEUtils for LWEUtils.RNG;

    uint256[37] s_packed;
    uint256[37] aFixed;
    uint16 bVal;

    function setUp() public {
        LWEUtils.RNG memory rng = LWEUtils.initRNG(9999);
        uint256[] memory s_secret = LWEUtils.generateSecret(rng);
        (uint256[] memory a, uint256 b) = LWEUtils.encrypt(s_secret, 0, rng);

        uint256[] memory aPacked = LWEPacking.packVector12(a);
        uint256[] memory sPacked = LWEPacking.packVector12(s_secret);

        for (uint256 i = 0; i < 37; i++) {
            aFixed[i] = aPacked[i];
            s_packed[i] = sPacked[i];
        }
        bVal = uint16(b);

        // baseTolerance=10, multiplier=1, maxTolerance=512, duration=1 day
        game = new RustyLock(aFixed, bVal, 10, 1, 512, 1 days);
    }

    // ── Happy path ─────────────────────────────────────────────────

    function test_WinGame() public {
        assertEq(game.getTolerance(), 10);

        game.contribute{value: 10 ether}();
        assertEq(game.getTolerance(), 20);

        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);

        uint256 preBalance = address(this).balance;
        game.solve(s_packed);
        uint256 postBalance = address(this).balance;

        assertEq(postBalance - preBalance, 10 ether);
        assertTrue(game.solved());
    }

    // ── Commit-reveal reverts ──────────────────────────────────────

    function test_RevertSolveWithoutCommit() public {
        game.contribute{value: 10 ether}();
        vm.expectRevert("No commit found");
        game.solve(s_packed);
    }

    function test_RevertSolveTooEarly() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.expectRevert("Reveal too early");
        game.solve(s_packed);
    }

    function test_RevertSolveInvalidReveal() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        uint256[37] memory wrong;
        vm.expectRevert("Invalid reveal");
        game.solve(wrong);
    }

    // ── Post-solve reverts ─────────────────────────────────────────

    function test_RevertCommitAfterSolved() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        game.solve(s_packed);

        vm.expectRevert("Already solved");
        game.commit(commitHash);
    }

    function test_RevertContributeAfterSolved() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        game.solve(s_packed);

        vm.expectRevert("Already solved");
        game.contribute{value: 1 ether}();
    }

    // ── Tolerance cap ──────────────────────────────────────────────

    function test_ToleranceCap() public {
        game.contribute{value: 2000 ether}();
        assertEq(game.getTolerance(), 512);
    }

    // ── Constructor boundary tests ─────────────────────────────────

    function test_ConstructorRevertMaxToleranceAtBoundary() public {
        vm.expectRevert("Max tolerance must be < q/4");
        new RustyLock(aFixed, bVal, 10, 1, 1024, 1 days);
    }

    function test_ConstructorSucceedsAtMaxBoundary() public {
        RustyLock g = new RustyLock(aFixed, bVal, 10, 1, 1023, 1 days);
        assertEq(g.maxTolerance(), 1023);
    }

    function test_ConstructorRevertBExceedsModulus() public {
        vm.expectRevert(RustyLock.InvalidB.selector);
        new RustyLock(aFixed, uint16(4096), 10, 1, 512, 1 days);
    }

    function test_ConstructorRevertMaxLessThanBase() public {
        vm.expectRevert("Max must exceed base");
        new RustyLock(aFixed, bVal, 100, 1, 50, 1 days);
    }

    function test_ConstructorRevertZeroDuration() public {
        vm.expectRevert("Duration must be > 0");
        new RustyLock(aFixed, bVal, 10, 1, 512, 0);
    }

    // ── Timeout & withdrawal ───────────────────────────────────────

    function test_WithdrawAfterExpiry() public {
        game.contribute{value: 5 ether}();
        assertEq(game.deposits(address(this)), 5 ether);

        // Warp past expiry
        vm.warp(block.timestamp + 1 days + 1);

        uint256 preBalance = address(this).balance;
        game.withdraw();
        uint256 postBalance = address(this).balance;

        assertEq(postBalance - preBalance, 5 ether);
        assertEq(game.deposits(address(this)), 0);
    }

    function test_RevertWithdrawBeforeExpiry() public {
        game.contribute{value: 5 ether}();
        vm.expectRevert("Game not expired");
        game.withdraw();
    }

    function test_RevertWithdrawAfterSolved() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);
        game.solve(s_packed);

        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert("Game was solved");
        game.withdraw();
    }

    function test_RevertWithdrawNoDeposit() public {
        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert("No deposit");
        game.withdraw();
    }

    function test_RevertContributeAfterExpiry() public {
        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert("Game expired");
        game.contribute{value: 1 ether}();
    }

    function test_RevertCommitAfterExpiry() public {
        vm.warp(block.timestamp + 1 days + 1);
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        vm.expectRevert("Game expired");
        game.commit(commitHash);
    }

    function test_RevertSolveAfterExpiry() public {
        game.contribute{value: 10 ether}();
        bytes32 commitHash = keccak256(abi.encode(address(this), s_packed));
        game.commit(commitHash);
        vm.roll(block.number + 2);

        vm.warp(block.timestamp + 1 days + 1);
        vm.expectRevert("Game expired");
        game.solve(s_packed);
    }

    function test_MultipleDepositorsWithdraw() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        vm.deal(alice, 10 ether);
        vm.deal(bob, 20 ether);

        vm.prank(alice);
        game.contribute{value: 3 ether}();
        vm.prank(bob);
        game.contribute{value: 7 ether}();

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(alice);
        game.withdraw();
        assertEq(alice.balance, 10 ether); // got 3 back

        vm.prank(bob);
        game.withdraw();
        assertEq(bob.balance, 20 ether); // got 7 back
    }

    // ── Transfer failure ───────────────────────────────────────────

    function test_RevertSolveWhenRecipientReverts() public {
        // Deploy game with initial ETH
        RustyLock g = new RustyLock{value: 1 ether}(aFixed, bVal, 10, 1, 512, 1 days);

        // Create a recipient that can't receive ETH
        RevertingRecipient recipient = new RevertingRecipient(g);

        // Fund recipient so it can call functions
        vm.deal(address(recipient), 10 ether);

        // Contribute from recipient
        vm.prank(address(recipient));
        g.contribute{value: 10 ether}();

        // Commit
        recipient.commitAndSolve(s_packed);
        vm.roll(block.number + 2);

        // Solve should revert because recipient can't receive ETH
        vm.prank(address(recipient));
        vm.expectRevert("Transfer failed");
        recipient.reveal(s_packed);
    }

    function test_ConstructorFundedWithdrawAfterExpiry() public {
        // Deploy with initial ETH
        RustyLock g = new RustyLock{value: 5 ether}(aFixed, bVal, 10, 1, 512, 1 days);
        assertEq(g.deposits(address(this)), 5 ether);

        vm.warp(block.timestamp + 1 days + 1);

        uint256 pre = address(this).balance;
        g.withdraw();
        uint256 post = address(this).balance;
        assertEq(post - pre, 5 ether);
    }

    receive() external payable {}
}
