// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RustyLock
 * @notice A Progressive Lattice Puzzle with commit-reveal MEV protection.
 * The noise tolerance increases as more ETH is deposited.
 * The first to find a vector 's' that satisfies the relaxed LWE equation wins the pot.
 * Solutions require a two-phase commit-reveal to prevent frontrunning.
 */
contract RustyLock {
    uint256 constant Q = 4096;
    uint256 constant Q_MASK = 0xFFF;
    uint256 constant N = 768;
    uint256 public constant COMMIT_DELAY = 2;

    struct LWEEntry {
        uint256[] a;
        uint256 b;
    }
    LWEEntry public puzzle;

    uint256 public immutable baseTolerance;
    uint256 public immutable toleranceMultiplier;
    uint256 public immutable maxTolerance;

    bool public solved;

    struct Commitment {
        bytes32 hash;
        uint256 blockNumber;
    }
    mapping(address => Commitment) private _commits;

    event PotIncreased(address contributor, uint256 amount, uint256 newTolerance);
    event Committed(address solver, bytes32 commitHash, uint256 blockNumber);
    event Winner(address winner, uint256 prize, uint256 error);

    constructor(
        uint256[] memory _a,
        uint256 _b,
        uint256 _baseTolerance,
        uint256 _toleranceMultiplier,
        uint256 _maxTolerance
    ) payable {
        require(_a.length == N, "Invalid dimension");
        require(_maxTolerance > _baseTolerance, "Max must exceed base");
        require(_maxTolerance <= Q / 2, "Max tolerance must be <= q/2");
        puzzle = LWEEntry(_a, _b);
        baseTolerance = _baseTolerance;
        toleranceMultiplier = _toleranceMultiplier;
        maxTolerance = _maxTolerance;
    }

    function contribute() external payable {
        require(!solved, "Already solved");
        require(msg.value > 0, "Must contribute ETH");
        emit PotIncreased(msg.sender, msg.value, getTolerance());
    }

    function getTolerance() public view returns (uint256) {
        uint256 raw = baseTolerance + (address(this).balance * toleranceMultiplier) / 1 ether;
        return raw < maxTolerance ? raw : maxTolerance;
    }

    /// @notice Phase 1: commit hash of your solution.
    function commit(bytes32 commitHash) external {
        require(!solved, "Already solved");
        _commits[msg.sender] = Commitment({hash: commitHash, blockNumber: block.number});
        emit Committed(msg.sender, commitHash, block.number);
    }

    /// @notice Phase 2: reveal and verify solution.
    function solve(uint256[] calldata s) external {
        require(!solved, "Already solved");
        require(s.length == N, "Invalid dimension");

        Commitment memory c = _commits[msg.sender];
        require(c.blockNumber > 0, "No commit found");
        require(block.number >= c.blockNumber + COMMIT_DELAY, "Reveal too early");
        require(keccak256(abi.encode(msg.sender, s)) == c.hash, "Invalid reveal");

        uint256 _q = Q;
        uint256 _b = puzzle.b;
        uint256 inner_prod = 0;

        uint256[] memory a_mem = puzzle.a;

        assembly {
            let a_ptr := add(a_mem, 32)
            let s_base := s.offset
            let i := 0

            for {} lt(i, 768) { i := add(i, 32) } {
                inner_prod := add(inner_prod, mul(mload(a_ptr), calldataload(s_base)))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 32)), calldataload(add(s_base, 32))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 64)), calldataload(add(s_base, 64))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 96)), calldataload(add(s_base, 96))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 128)), calldataload(add(s_base, 128))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 160)), calldataload(add(s_base, 160))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 192)), calldataload(add(s_base, 192))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 224)), calldataload(add(s_base, 224))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 256)), calldataload(add(s_base, 256))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 288)), calldataload(add(s_base, 288))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 320)), calldataload(add(s_base, 320))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 352)), calldataload(add(s_base, 352))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 384)), calldataload(add(s_base, 384))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 416)), calldataload(add(s_base, 416))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 448)), calldataload(add(s_base, 448))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 480)), calldataload(add(s_base, 480))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 512)), calldataload(add(s_base, 512))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 544)), calldataload(add(s_base, 544))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 576)), calldataload(add(s_base, 576))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 608)), calldataload(add(s_base, 608))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 640)), calldataload(add(s_base, 640))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 672)), calldataload(add(s_base, 672))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 704)), calldataload(add(s_base, 704))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 736)), calldataload(add(s_base, 736))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 768)), calldataload(add(s_base, 768))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 800)), calldataload(add(s_base, 800))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 832)), calldataload(add(s_base, 832))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 864)), calldataload(add(s_base, 864))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 896)), calldataload(add(s_base, 896))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 928)), calldataload(add(s_base, 928))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 960)), calldataload(add(s_base, 960))))
                inner_prod := add(inner_prod, mul(mload(add(a_ptr, 992)), calldataload(add(s_base, 992))))

                a_ptr := add(a_ptr, 1024)
                s_base := add(s_base, 1024)
            }

            inner_prod := and(inner_prod, 0xFFF)
        }

        uint256 error;
        if (inner_prod > _b) {
            uint256 diff = inner_prod - _b;
            error = diff > _q / 2 ? _q - diff : diff;
        } else {
            uint256 diff = _b - inner_prod;
            error = diff > _q / 2 ? _q - diff : diff;
        }

        uint256 tolerance = getTolerance();
        require(error <= tolerance, "Solution not close enough");

        solved = true;
        delete _commits[msg.sender];
        uint256 prize = address(this).balance;
        emit Winner(msg.sender, prize, error);
        (bool success,) = payable(msg.sender).call{value: prize}("");
        require(success, "Transfer failed");
    }
}
