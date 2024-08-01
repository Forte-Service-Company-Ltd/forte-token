// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";

import {ProtocolToken} from "src/token/ProtocolToken.sol";


/**
 * @title Deploy Token Manager
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will deploy an Axelar Interchain Token Service Token Manager
 * @notice This token manager is used to manage the flow of tokens between chains.
 * Be sure to mint tokens on the foreign chain that is not the main distribution point.
 * ** Requires .env variables to be set with correct addresses **
 * Run Script:
 * forge script script/deployTokenManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract DeployTokenManager is Script {

    uint privateKey;
    address ownerAddress;
    address waveAddress;
    InterchainTokenService tokenService;
    bytes32 salt;


    function run() public {
        console.log("Deploy a Token Manager");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        waveAddress = vm.envAddress("TOKEN_ADDRESS");
        tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));
        salt = keccak256(abi.encode(vm.envString("SALT_STRING")));

        vm.startBroadcast(privateKey);
        
        bytes32 tokenId = tokenService.deployTokenManager(
            salt,
            "", 
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK, 
            abi.encode(abi.encodePacked(ownerAddress), waveAddress),
            0
        );

        console.log("TOKEN_ID=");
        console.logBytes32(tokenId);
        address tokenManagerAddress = tokenService.tokenManagerAddress(tokenId);
        console.log("TOKEN_MANAGER_ADDRESS=", tokenManagerAddress);
    
        tokenService.deployTokenManager(
            salt, 
            vm.envString("DESTINATION_CHAIN"),
            ITokenManagerType.TokenManagerType.MINT_BURN,
            abi.encode(abi.encodePacked(ownerAddress), vm.envAddress("FOREIGN_TOKEN_ADDRESS")), 
            0.01 ether // note: this may need to be adjusted depending on network conditions
        );

        setENVAddress("TOKEN_MANAGER_ADDRESS", vm.toString(tokenManagerAddress));
        setENVString("TOKEN_ID", vm.toString(tokenId));

        vm.stopBroadcast();
    }
}

