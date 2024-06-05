// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {ApplicationAppManager} from "tron/example/application/ApplicationAppManager.sol";

/**
<<<<<<<< HEAD:script/deployProtocolToken.s.sol
 * @title ERC20 Upggradeable Protocol Token  Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
 * Run Script:
 * forge script script/deployProtocolToken.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
========
 * @title ERC20 Upggradeable Wave Token  Script
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
>>>>>>>> e1c2165 (Documentation Refactor & Remove deployments directory in docs):script/Deploy_WaveToken.s.sol
 */

contract WaveTokenDeployScript is Script {
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

        /// Create ERC20 Upgradeable and Proxy 
        ProtocolToken waveToken = new ProtocolToken{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        vm.stopBroadcast();
        vm.startBroadcast(appConfigAdminKey);
        bytes memory callData = abi.encodeWithSelector(waveToken.initialize.selector, "Wave", "WAVE",address(applicationAppManager));
        ProtocolTokenProxy waveTokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}(address(waveToken), appConfigAdminAddress, callData); 
        console.log("Wave Token Proxy Address: ", address(waveTokenProxy));
        // note: Create2 is taking admin control, need to find a way to get around giving create2 deployer from foundry control possibly by making our own create2 deployer or by briefly giving it access and immediately removing it. 
        // more thoughts: potentially import different modifier onto the initialze function to make it not check msg.sender but tx.origin, but this might conflict with gnosis safe wallets
        vm.stopBroadcast();
    }

}