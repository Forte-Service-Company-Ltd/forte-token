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
 * @title ERC20 Upggradeable Protocol Token  Deployment Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy.
 * @notice Deploys an application ERC20U and Proxy.
 * ** Requires .env variables to be set with correct addresses **
 */

contract TokenDeployScript is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    uint256 minterAdminKey;
    address minterAdminAddress;
    uint256 proxyOwnerKey;
    address proxyOwnerAddress;
    string name = "Forte"; // Change Name here 
    string symbol = "FOR"; // Change Symbol here 

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
        ProtocolToken token = new ProtocolToken{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        ProtocolTokenProxy tokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(address(token), proxyOwnerAddress, "");
        
        ProtocolToken(address(tokenProxy)).initialize(name, symbol, address(ownerAddress)); 
        console.log("Token Proxy Address: ", address(tokenProxy));
        console.log("Token Proxy Admin Address: ", address(proxyOwnerAddress));
        console.log("Token Admin Address: ", address(ownerAddress));
        console.log("Token Minter Address: ", address(minterAdminAddress));

        ProtocolToken(address(tokenProxy)).grantRole(MINTER_ROLE, minterAdminAddress);
        if(keccak256(bytes(vm.envString("CURRENT_DEPLOYMENT"))) == keccak256(bytes("NATIVE"))) {
            setENVAddress("TOKEN_ADDRESS", vm.toString(address(tokenProxy)));
        } else {
            setENVAddress("FOREIGN_TOKEN_ADDRESS", vm.toString(address(tokenProxy)));
        }
        vm.stopBroadcast();
    }

}
