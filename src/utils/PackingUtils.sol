// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PackingUtils {
    uint256 constant ELEMENTS_PER_WORD = 21;
    uint256 constant BIT_WIDTH = 12;
    uint256 constant MASK = 0xFFF; // 12 bits set to 1

    /**
     * @notice Packs a vector of 12-bit integers into a packed uint256 array.
     * Each uint256 holds 21 elements.
     */
    function packVector(uint256[] memory input) internal pure returns (uint256[] memory packed) {
        uint256 n = input.length;
        uint256 packedSize = (n + ELEMENTS_PER_WORD - 1) / ELEMENTS_PER_WORD;
        packed = new uint256[](packedSize);

        uint256 currentWord = 0;
        uint256 countInWord = 0;
        uint256 wordIndex = 0;

        for (uint256 i = 0; i < n; i++) {
            require(input[i] < 4096, "Element exceeds 12 bits");
            
            // Shift the element to the left and OR it into the current word
            // We fill from LSB to MSB. 
            // Element 0: bits 0-11
            // Element 1: bits 12-23
            // ...
            currentWord |= (input[i] << (countInWord * BIT_WIDTH));
            countInWord++;

            if (countInWord == ELEMENTS_PER_WORD) {
                packed[wordIndex] = currentWord;
                wordIndex++;
                currentWord = 0;
                countInWord = 0;
            }
        }

        // Handle the last partial word if any
        if (countInWord > 0) {
            packed[wordIndex] = currentWord;
        }
    }

    /**
     * @notice Unpacks a packed uint256 array back into a vector of 12-bit integers.
     */
    function unpackVector(uint256[] memory packed, uint256 n) internal pure returns (uint256[] memory unpacked) {
        unpacked = new uint256[](n);
        
        uint256 wordIndex = 0;
        uint256 countInWord = 0;
        uint256 currentWord = packed[0];

        for (uint256 i = 0; i < n; i++) {
            // Extract 12 bits
            unpacked[i] = (currentWord >> (countInWord * BIT_WIDTH)) & MASK;
            countInWord++;

            if (countInWord == ELEMENTS_PER_WORD) {
                wordIndex++;
                if (wordIndex < packed.length) {
                    currentWord = packed[wordIndex];
                }
                countInWord = 0;
            }
        }
    }
}
