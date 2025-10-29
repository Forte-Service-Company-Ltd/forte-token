/// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/src/console2.sol";

/**
 * @title Example contract for testing the Foreign Call Encoding
 * @author @mpetersoCode55
 */
contract ForteAllowed {
    function exists(address _address) public pure returns(bool){
        console2.log("in exists()", _address);
        return true;
    }
}