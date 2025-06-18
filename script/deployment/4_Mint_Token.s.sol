// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import "script/deployUtil.s.sol";

/**
 * @title ERC20 Upggradeable Protocol Token Deployment Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy then connect them to the Protocol contracts.
 * @notice Deploys an application ERC20U and Proxy and connects them to the Protocol Contracts.
 * ** Requires .env variables to be set with correct addresses **
 */

contract MintTokenScript is DeployScriptUtil {

    function setUp() public {}

    function run() public {

        address tokenProxyAddress;
        tokenProxyAddress = vm.envAddress("TOKEN_ADDRESS");
        // admins        
        address treasuryAdmin1 = vm.envAddress("FRE_TREASURY_1_ADMIN");
        uint256 treasuryAdmin1Key = vm.envUint("FRE_TREASURY_1_ADMIN_PRIVATE_KEY");

        vm.startBroadcast(treasuryAdmin1Key);
        ProtocolToken(tokenProxyAddress).mint(treasuryAdmin1, 1_000_000_000 * 10E18);
        
        vm.stopBroadcast();
    }


}
