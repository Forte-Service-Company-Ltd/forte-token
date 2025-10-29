// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 
import "test/token/ERC20UCommonTests.t.sol";

/**
 * ERC20 Upgradeable tests 
 */

contract ProtocolTokenTest is TestCommon, ERC20UCommonTests {
    function setUp() public endWithStopPrank {
        setUpTokenWithEngine();
        testDeployments = true;
    }
}