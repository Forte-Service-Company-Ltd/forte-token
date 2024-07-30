// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import {ApplicationAppManager} from "tron/example/application/ApplicationAppManager.sol";
import {HandlerDiamond} from "tron/client/token/handler/diamond/HandlerDiamond.sol";
import {ERC20HandlerMainFacet} from "tron/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
import "script/deployUtil.s.sol";

/**
 * @title ERC20 Upggradeable Protocol Token  Deployment Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
 */

contract WaveTokenDeployScript is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    uint256 minterAdminKey;
    address minterAdminAddress;
    uint256 proxyOwnerKey;
    address proxyOwnerAddress;

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        
        /// switch to the config admin
        minterAdminKey = vm.envUint("MINTER_ADMIN_KEY");
        minterAdminAddress = vm.envAddress("MINTER_ADMIN");

        proxyOwnerKey = vm.envUint("PROXY_OWNER_KEY");
        proxyOwnerAddress = vm.envAddress("PROXY_OWNER");

        /// Create ERC20 Upgradeable and Proxy 
        ProtocolToken waveToken = new ProtocolToken{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        ProtocolTokenProxy waveTokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(address(waveToken), proxyOwnerAddress, "");
        
        ProtocolToken(address(waveTokenProxy)).initialize("Wave", "WAVE", address(ownerAddress)); 
        console.log("Wave Token Proxy Address: ", address(waveTokenProxy));
        console.log("Wave Token Proxy Admin Address: ", address(proxyOwnerAddress));
        console.log("Wave Token Admin Address: ", address(ownerAddress));
        console.log("Wave Token Minter Address: ", address(minterAdminAddress));

        ProtocolToken(address(waveTokenProxy)).grantRole(MINTER_ROLE, minterAdminAddress);
        if(keccak256(bytes(vm.envString("CURRENT_DEPLOYMENT"))) == keccak256(bytes("NATIVE"))) {
            setENVAddress("TOKEN_ADDRESS", vm.toString(address(waveTokenProxy)));
        } else {
            setENVAddress("FOREIGN_TOKEN_ADDRESS", vm.toString(address(waveTokenProxy)));
        }
        vm.stopBroadcast();
    }

}