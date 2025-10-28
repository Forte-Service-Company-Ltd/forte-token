// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Script.sol";
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

contract TokenForProtocolDeployScript_1 is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    uint256 minterAdminKey;
    address minterAdminAddress;
    address proxyOwnerAddress;
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint64 constant END_PAUSE = 9999999999;
    string name = "Forte"; // Change Name here 
    string symbol = "FOR"; // Change Symbol here  
        

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        proxyOwnerAddress = vm.envAddress("PROXY_OWNER");
        vm.startBroadcast(privateKey);

        /// switch to the config admin
        minterAdminKey = vm.envUint("MINTER_ADMIN_KEY");
        minterAdminAddress = vm.envAddress("MINTER_ADMIN");

        /// Create ERC20 Upgradeable and Proxy 
        ProtocolToken token = new ProtocolToken{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        ProtocolTokenProxy tokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(address(token), proxyOwnerAddress, "");
        ProtocolToken(address(tokenProxy)).initialize(name, symbol, address(ownerAddress)); 

        ProtocolToken(address(tokenProxy)).grantRole(MINTER_ROLE, minterAdminAddress);
        setENVAddress("TOKEN_ADDRESS", vm.toString(address(tokenProxy)));
        vm.stopBroadcast();

    }


}
