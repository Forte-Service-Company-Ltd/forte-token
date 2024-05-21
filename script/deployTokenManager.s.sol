// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "axelar-gmp-sdk-solidity/deploy/Create3Deployer.sol";

import "src/token/Wave.sol";

contract DeployTokenManager is Script {

    uint privateKey;
    address ownerAddress;

    address waveAddress;


    function run() public {
        console.log("Deploy a Token");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        waveAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(privateKey);
        try this.deployToken(){
            console.log("Logic Success");
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
        }
        vm.stopBroadcast();
    }

    function deployToken() external {
        console.log("deployToken");
        // 0x534d454c4c494e475f53414c5453 is bytes32("SMELLING_SALTS")
        wave = new Wave{salt: 0x534d454c4c494e475f53414c5453}(ownerAddress, minterAddress);
    }
}