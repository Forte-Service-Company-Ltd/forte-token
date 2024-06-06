// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {ApplicationAppManager} from "tron/example/application/ApplicationAppManager.sol";

/**
 * @title ERC20 Upggradeable Protocol Token  Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
 */

contract WaveTokenDeployScript is Script {
    uint256 privateKey;
    address ownerAddress;
    uint256 appConfigAdminKey;
    address appConfigAdminAddress;
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
        bytes memory callData = abi.encodeWithSelector(waveToken.initialize.selector, "Wave", "WAVE", address(ownerAddress));
        ProtocolTokenProxy waveTokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}(address(waveToken), appConfigAdminAddress, callData); 
        console.log("Wave Token Proxy Address: ", address(waveTokenProxy));
        ProtocolToken(address(waveTokenProxy)).grantRole(MINTER_ROLE, ownerAddress);
        vm.stopBroadcast();
    }

}