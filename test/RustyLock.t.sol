// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RustyLock.sol";
import {LWEPacking} from "evm-lwe-math/src/LWEPacking.sol";
import "./utils/LWEUtils.sol";

contract RustyLockTest is Test {
    RustyLock public game;
    using LWEUtils for LWEUtils.RNG;

    uint256[37] s_packed;

    function setUp() public {
        LWEUtils.RNG memory rng = LWEUtils.initRNG(9999);
        uint256[] memory s_secret = LWEUtils.generateSecret(rng);
        (uint256[] memory a, uint256 b) = LWEUtils.encrypt(s_secret, 0, rng);

        // Pack vectors for the new contract interface
        uint256[] memory aPacked = LWEPacking.packVector12(a);
        uint256[] memory sPacked = LWEPacking.packVector12(s_secret);

        uint256[37] memory aFixed;
        for (uint256 i = 0; i < 37; i++) {
            aFixed[i] = aPacked[i];
            s_packed[i] = sPacked[i];
        }

        // baseTolerance=10, multiplier=1, maxTolerance=1024
        game = new RustyLock(aFixed, uint16(b), 10, 1, 512);
    }

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

    function test_ToleranceCap() public {
        game.contribute{value: 2000 ether}();
        assertEq(game.getTolerance(), 512);
    }

    function test_RevertAfterSolved() public {
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

    receive() external payable {}
}
