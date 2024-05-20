// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "interchain-token-service/interfaces/IInterchainTokenService.sol";

contract DeployToken is Script {

    uint privateKey;
    address interchainTokenServiceAddr;
    IInterchainTokenService interchainTokenService;
    Wave wave;


    function run() public {
        console.log("Deploy a Token Manager");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        interchainTokenServiceAddr = vm.envAddress("INTERCHAIN_TOKEN_SERVICE");
        interchainTokenService = IInterchainTokenService(interchainTokenServiceAddr);
        minterAddress = vm.envAddress("DEPLOYMENT_MINTER");

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
        wave = new Wave(ownerAddress, minterAddress);
    }
}