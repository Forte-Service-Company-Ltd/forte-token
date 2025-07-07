// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {ApplicationAppManager} from "rulesEngine/example/application/ApplicationAppManager.sol";
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

contract TokenForProtocolDeployScript_3 is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    uint256 minterAdminKey;
    address minterAdminAddress;
    uint256 proxyOwnerKey;
    address proxyOwnerAddress;
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint64 constant END_PAUSE = 9999999999;
    string name = "Forte"; // Change Name here 
    string symbol = "FOR"; // Change Symbol here  
        

    function setUp() public {}

    function run() public {

        address appManagerAddress = vm.envAddress("APPLICATION_APP_MANAGER");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        // admins
        uint256 appAdminKey = vm.envUint("FRE_APP_ADMIN_PRIVATE_KEY");
        address ruleAdmin = vm.envAddress("FRE_RULE_ADMIN");
        uint256 ruleAdminKey = vm.envUint("FRE_RULE_ADMIN_PRIVATE_KEY");
        address treasuryAdmin1 = vm.envAddress("FRE_TREASURY_1_ADMIN");

        vm.startBroadcast(appAdminKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(appManagerAddress);
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken(symbol, tokenAddress);
        // set forte foundation as Treasury accounts
        applicationAppManager.addTreasuryAccount(treasuryAdmin1);
        applicationAppManager.addRuleAdministrator(ruleAdmin);
        vm.stopBroadcast();
        
        vm.startBroadcast(ruleAdminKey);
        // Pause Token for everyone else
        applicationAppManager.addPauseRule(uint64(block.timestamp)+120, END_PAUSE);
        
        vm.stopBroadcast();
    }


}
