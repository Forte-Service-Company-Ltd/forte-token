// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";

import {ProtocolToken} from "src/token/ProtocolToken.sol";

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
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK,
            abi.encode(abi.encodePacked(ownerAddress), vm.envAddress("FOREIGN_TOKEN_ADDRESS")), 
            0.01 ether // note: this may need to be adjusted depending on network conditions
        );

        vm.stopBroadcast();
    }
}

