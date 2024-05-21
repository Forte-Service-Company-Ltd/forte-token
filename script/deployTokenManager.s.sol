// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "interchain-token-service/InterchainTokenService.sol";

import "src/token/Wave.sol";

contract DeployTokenManager is Script {

    uint privateKey;
    address ownerAddress;
    address waveAddress;
    InterchainTokenService tokenService;


    function run() public {
        console.log("Deploy a Token Manager");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        waveAddress = vm.envAddress("TOKEN_ADDRESS");
        tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));

        
        vm.startBroadcast(privateKey);
        try this.deployTokenManager(){
            console.log("Logic Success");
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
        }
        vm.stopBroadcast();
    }

    function deployTokenManager() external {
        console.log("deployTokenManager");
        // 0x534d454c4c494e475f53414c5453 is bytes32("SMELLING_SALTS")
        bytes memory addrPlacement = abi.encode(ownerAddress);
        bytes32 tokenId = tokenService.deployTokenManager(
            bytes32(0x534d454c4c494e475f53414c5453),
            "", 
            2, 
            abi.encode(("bytes", "address"), addrPlacement, waveAddress),
            .01 ether
        );

        console.log("TOKEN_ID=%s", tokenId);
    }
}

