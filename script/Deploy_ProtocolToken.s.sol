// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {ApplicationAppManager} from "tron/example/application/ApplicationAppManager.sol";

/**
 * @title ERC20 Upggradeable Protocol Token  Script
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
 * Run Script:
 * forge script example/script/Application_Deploy_01_AppManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv

 */

contract ProtocolTokenDeployScript is Script {
    uint256 privateKey;
    address ownerAddress;
    uint256 appConfigAdminKey;
    address appConfigAdminAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve the App Manager from env addresses 
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        
        /// switch to the config admin
        appConfigAdminKey = vm.envUint("CONFIG_APP_ADMIN_KEY");
        appConfigAdminAddress = vm.envAddress("CONFIG_APP_ADMIN");
        vm.startBroadcast(appConfigAdminKey);

        /// Create ERC20 Upgradeable and Proxy 
        ProtocolToken waveToken = new ProtocolToken();
        bytes memory callData = abi.encodeWithSelector(waveToken.initialize.selector, address(appConfigAdminAddress), address(applicationAppManager));
        ProtocolTokenProxy waveTokenProxy = new ProtocolTokenProxy(address(waveToken), appConfigAdminAddress, callData); 

        ProtocolToken(address(waveTokenProxy)).initialize("Wave", "WAVE",address(applicationAppManager));

        vm.stopBroadcast();
    }
}
