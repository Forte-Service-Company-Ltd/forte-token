// SPDX-License-Identifier: UNLICENSED
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

contract TokenForProtocolDeployScript is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    uint256 minterAdminKey;
    address minterAdminAddress;
    uint256 proxyOwnerKey;
    address proxyOwnerAddress;
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string name = "Forte"; // Change Name here 
    string symbol = "FOR"; // Change Symbol here  
        

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
        bool native = keccak256(bytes(vm.envString("CURRENT_DEPLOYMENT"))) == keccak256(bytes("NATIVE"));

        address appManagerAddress;
        address handlerAddress;
        address protocolAddress;

        if(native) {
            appManagerAddress = vm.envAddress("APPLICATION_APP_MANAGER");
            handlerAddress = vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS");
            protocolAddress = vm.envAddress("RULE_PROCESSOR_DIAMOND");
        } else {
            appManagerAddress = vm.envAddress("FOREIGN_APPLICATION_APP_MANAGER");
            handlerAddress = vm.envAddress("FOREIGN_APPLICATION_ERC20_HANDLER_ADDRESS");
            protocolAddress = vm.envAddress("FOREIGN_RULE_PROCESSOR_DIAMOND");
        }

        /// Create ERC20 Upgradeable and Proxy 
        ProtocolToken Token = new ProtocolToken{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        ProtocolTokenProxy TokenProxy = new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(address(Token), proxyOwnerAddress, "");
        ProtocolToken(address(TokenProxy)).initialize(name, symbol, address(ownerAddress)); 
        console.log("Token Proxy Address: ", address(TokenProxy));

        ProtocolToken(address(TokenProxy)).grantRole(MINTER_ROLE, minterAdminAddress);
        vm.stopBroadcast();

        /// Connect to Asset Handler and register with App Manager
        uint256 frePrivateKey = vm.envUint("FRE_DEPLOYMENT_OWNER_KEY");
        vm.startBroadcast(frePrivateKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(appManagerAddress);
        HandlerDiamond applicationCoinHandlerDiamond = HandlerDiamond(payable(handlerAddress));
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond)).initialize(protocolAddress, address(applicationAppManager), address(TokenProxy));
        uint256 freAppAdminKey = vm.envUint("FRE_APP_ADMIN_PRIVATE_KEY");
        vm.stopBroadcast();
        vm.startBroadcast(privateKey);
        ProtocolToken(address(TokenProxy)).connectHandlerToToken(address(applicationCoinHandlerDiamond));
        vm.stopBroadcast();
        vm.startBroadcast(freAppAdminKey);
        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("FOR", address(TokenProxy));
        if(native) {
            setENVAddress("TOKEN_ADDRESS", vm.toString(address(TokenProxy)));
        } else {
            setENVAddress("FOREIGN_TOKEN_ADDRESS", vm.toString(address(TokenProxy)));
        }
        vm.stopBroadcast();
        vm.startBroadcast(minterAdminKey);
        ProtocolToken(address(TokenProxy)).mint(minterAdminAddress, vm.envUint("MINT_AMOUNT"));
        vm.stopBroadcast();
    }

}
