// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {HandlerDiamond} from "rulesEngine/client/token/handler/diamond/HandlerDiamond.sol";
import {ERC20HandlerMainFacet} from "rulesEngine/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
import "script/deployUtil.s.sol";

/**
 * @title ERC20 Upggradeable Protocol Token Deployment Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy then connect them to the Protocol contracts.
 * @notice Deploys an application ERC20U and Proxy and connects them to the Protocol Contracts.
 * ** Requires .env variables to be set with correct addresses **
 */

contract TokenForProtocolDeployScript is DeployScriptUtil {

    function setUp() public {}

    function run() public {

        address appManagerAddress = vm.envAddress("APPLICATION_APP_MANAGER");
        address handlerAddress = vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS");
        address protocolAddress = vm.envAddress("RULE_PROCESSOR_DIAMOND");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        /// Connect to Asset Handler and register with App Manager
        uint256 frePrivateKey = vm.envUint("FRE_DEPLOYMENT_OWNER_KEY");
        vm.startBroadcast(frePrivateKey);
        HandlerDiamond applicationCoinHandlerDiamond = HandlerDiamond(
            payable(handlerAddress)
        );
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond))
            .initialize(
                protocolAddress,
                appManagerAddress,
                tokenAddress
            );
        uint256 freAppAdminKey = vm.envUint("FRE_APP_ADMIN_PRIVATE_KEY");
        vm.stopBroadcast();
        vm.startBroadcast(freAppAdminKey);
        ProtocolToken(tokenAddress).connectHandlerToToken(
            address(applicationCoinHandlerDiamond)
        );
        vm.stopBroadcast();
    }
}
