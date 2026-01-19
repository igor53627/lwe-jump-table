// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RustyLock
 * @notice A Progressive Lattice Puzzle.
 * The noise tolerance increases as more ETH is deposited.
 * The first to find a vector 's' that satisfies the relaxed LWE equation wins the pot.
 */
contract RustyLock {
    uint256 constant q = 4096;
    uint256 constant n = 768;
    
    // The Puzzle: LWE sample (a, b)
    // b = <a, s_secret> + e
    struct LWEEntry {
        uint256[] a;
        uint256 b;
    }
    LWEEntry public puzzle;
    
    // Game State
    uint256 public baseTolerance = 10; // Initial allowed error (very strict)
    uint256 public toleranceMultiplier = 1; // Tolerance gained per ETH deposited
    
    event PotIncreased(address contributor, uint256 amount, uint256 newTolerance);
    event Winner(address winner, uint256 prize, uint256 error);

    constructor(uint256[] memory _a, uint256 _b) payable {
        require(_a.length == n, "Invalid dimension");
        puzzle = LWEEntry(_a, _b);
    }

    /**
     * @notice Deposit ETH to increase the pot and weaken the lock.
     * Each 1 ETH deposited adds 'toleranceMultiplier' to the allowed error.
     */
    function contribute() external payable {
        require(msg.value > 0, "Must contribute ETH");
        emit PotIncreased(msg.sender, msg.value, getTolerance());
    }

    /**
     * @notice The current error tolerance allowed.
     * Starts at baseTolerance and increases with the balance.
     */
    function getTolerance() public view returns (uint256) {
        // Linear scaling: 1 ETH = +1 unit of tolerance (roughly)
        // Adjust multiplier based on 'q'. 
        // q=4096. Max tolerance possible is ~2048.
        // If we want the game to last until ~100 ETH, multiplier should be ~20.
        uint256 balanceTolerance = (address(this).balance * toleranceMultiplier) / 1 ether;
        return baseTolerance + balanceTolerance;
    }

    /**
     * @notice Submit a solution 's'.
     * If | b - <a, s> | < currentTolerance, you win the entire balance.
     */
    function solve(uint256[] calldata s) external {
        require(s.length == n, "Invalid dimension");
        
        uint256 _q = q;
        uint256 _b = puzzle.b;
        uint256 inner_prod = 0;
        
        // Optimized Inner Product <a, s>
        // Loading 'a' from storage is expensive (SLOADs). 
        // For a high-stakes game, gas cost (~20M) is acceptable for the winner.
        // To optimize, we could store 'a' in code or use IPFS hash (but then on-chain verifiction is hard).
        // Here we just accept the SLOAD cost for the prototype.
        
        // Actually, we can't do SLOAD easily in a loop in pure Yul without manual storage slot math.
        // Let's use Solidity loop for simplicity here, or simple unrolled Solidity.
        
        uint256[] memory a_mem = puzzle.a; // Copy to memory (Expensive but clean)
        
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
             
             inner_prod := mod(inner_prod, _q)
        }

        uint256 error;
        if (inner_prod > _b) {
            // Distance is min(|b-ip|, |b-ip+q|) ? No, standard modular distance.
            // d(x, y) = min(|x-y|, q - |x-y|)
            uint256 diff = inner_prod - _b;
            if (diff > _q / 2) { error = _q - diff; } else { error = diff; }
        } else {
            uint256 diff = _b - inner_prod;
            if (diff > _q / 2) { error = _q - diff; } else { error = diff; }
        }

        uint256 tolerance = getTolerance();
        require(error <= tolerance, "Solution not close enough");

        uint256 prize = address(this).balance;
        payable(msg.sender).transfer(prize);
        emit Winner(msg.sender, prize, error);
    }
}
