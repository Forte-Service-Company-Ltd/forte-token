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
 * @title ERC20 Upggradeable Protocol Token Deployment Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an ERC20 Upgradeable fungible token and Proxy then connect them to the Protocol contracts.
 * @notice Deploys an application ERC20U and Proxy and connects them to the Protocol Contracts.
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
        vm.stopBroadcast();
        vm.startBroadcast(minterAdminKey);
        ProtocolToken(address(waveTokenProxy)).initialize("Wave", "WAVE", address(minterAdminAddress)); 
        console.log("Wave Token Proxy Address: ", address(waveTokenProxy));

        ProtocolToken(address(waveTokenProxy)).grantRole(MINTER_ROLE, minterAdminAddress);
        vm.stopBroadcast();

        /// Connect to Asset Handler and register with App Manager
        uint256 tronPrivateKey = vm.envUint("TRON_DEPLOYMENT_OWNER_KEY");
        address tronOwnerAddress = vm.envAddress("TRON_DEPLOYMENT_OWNER");
        vm.startBroadcast(tronPrivateKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        HandlerDiamond applicationCoinHandlerDiamond = HandlerDiamond(payable(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS")));
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(waveTokenProxy));
        uint256 tronAppAdminKey = vm.envUint("TRON_APP_ADMIN_PRIVATE_KEY");
        address tronAppAdminAddress = vm.envAddress("TRON_APP_ADMIN");
        vm.stopBroadcast();
        vm.startBroadcast(minterAdminKey);
        ProtocolToken(address(waveTokenProxy)).connectHandlerToToken(address(applicationCoinHandlerDiamond));

        vm.stopBroadcast();
        vm.startBroadcast(tronAppAdminKey);
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("WAVE", address(waveTokenProxy));
        setENVAddress("TOKEN_ADDRESS", vm.toString(address(waveTokenProxy)));
    }

}