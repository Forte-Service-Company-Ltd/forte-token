// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "test/token/TestCommon.sol"; 


/**
 * @title ERC20Common
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4
 * @dev This is the common module for ERC20U invariant tests.
 */
abstract contract ERC20UCommon is TestCommon {
    address msgSender;
    uint256 value;
    uint256 amount;
    address target;
    address USER1;
    address USER2;
    address USER3;
    
    function prepERC20AndEnvironment() public {
        setUpTokenWithHandler();
        switchToAppAdministrator();
        (USER1, USER2, USER3, target) = _get4RandomAddresses(uint8(block.timestamp % ADDRESSES.length));
        amount = block.timestamp;
        switchToMinterAdmin();
        ProtocolToken(address(protocolTokenProxy)).mint(USER1, 10 * ATTO);
        ProtocolToken(address(protocolTokenProxy)).mint(USER2, 10 * ATTO);
        ProtocolToken(address(protocolTokenProxy)).mint(USER3, 10 * ATTO);
        vm.stopPrank();
        targetSender(USER1);
        targetSender(USER2);
        targetSender(USER3);
        targetSender(target);
        targetContract(address(protocolToken));
    }
}