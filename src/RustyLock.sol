// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RustyLock
 * @notice A Progressive Lattice Puzzle with commit-reveal MEV protection.
 * The noise tolerance increases as more ETH is deposited.
 * The first to find a vector 's' that satisfies the relaxed LWE equation wins the pot.
 * Solutions require a two-phase commit-reveal to prevent frontrunning.
 *
 * Uses packed 12-bit storage (21 elements per uint256, 37 words for n=768)
 * with SWAR inner product for gas efficiency.
 */
contract RustyLock {
    uint256 constant Q = 4096;
    uint256 constant Q_MASK = 0xFFF;
    uint256 constant N = 768;
    uint256 constant PACKED_SIZE = 37; // ceil(768/21)
    uint256 public constant COMMIT_DELAY = 2;

    uint256[37] public puzzleA;
    uint16 public puzzleB;

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

    error InvalidDimension();
    error InvalidB();

    constructor(
        uint256[37] memory _aPacked,
        uint16 _b,
        uint256 _baseTolerance,
        uint256 _toleranceMultiplier,
        uint256 _maxTolerance
    ) payable {
        if (_b >= Q) revert InvalidB();
        require(_maxTolerance > _baseTolerance, "Max must exceed base");
        require(_maxTolerance < Q / 4, "Max tolerance must be < q/4");
        for (uint256 i = 0; i < PACKED_SIZE; i++) {
            puzzleA[i] = _aPacked[i];
        }
        puzzleB = _b;
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

    /// @notice Phase 2: reveal and verify packed solution.
    function solve(uint256[37] calldata sPacked) external {
        require(!solved, "Already solved");

        Commitment memory c = _commits[msg.sender];
        require(c.blockNumber > 0, "No commit found");
        require(block.number >= c.blockNumber + COMMIT_DELAY, "Reveal too early");
        require(keccak256(abi.encode(msg.sender, sPacked)) == c.hash, "Invalid reveal");

        uint256 _b = puzzleB;
        uint256 inner_prod = 0;

        // Packed SWAR inner product: 37 words × 21 elements/word = 777 lanes
        // N=768, so last word has 9 trailing zero-padded lanes (768 mod 21 = 12 used).
        // Trailing zeros contribute 0 to inner product, so no masking needed
        // as long as both a and s are packed by the same LWEPacking.packVector12.
        assembly {
            let mask := 0xFFF

            // Compute storage slot for puzzleA[0]
            // puzzleA is at slot 0 (first state variable after constants)
            let baseSlot := puzzleA.slot

            // sPacked calldata offset
            let s_ptr := sPacked

            for { let i := 0 } lt(i, 37) { i := add(i, 1) } {
                let w_a := sload(add(baseSlot, i))
                let w_s := calldataload(s_ptr)

                // Unroll 21 elements (SWAR unpacking)
                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))
                w_a := shr(12, w_a)
                w_s := shr(12, w_s)

                inner_prod := add(inner_prod, mul(and(w_a, mask), and(w_s, mask)))

                s_ptr := add(s_ptr, 32)
            }

            inner_prod := and(inner_prod, 0xFFF)
        }

        uint256 _q = Q;
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
