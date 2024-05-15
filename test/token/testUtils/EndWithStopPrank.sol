// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

/**
 * @title End With Stop Prank
 * @author @ShaneDuncan602 @TJ-Everett @VoR0220 @Palmerg4
 * @dev encapsulates the modifier used in the whole test directory to end a test function
 * with a stopPrank command.
 */

abstract contract EndWithStopPrank is Test {
    modifier endWithStopPrank() {
        _;
        vm.stopPrank();
    }
}