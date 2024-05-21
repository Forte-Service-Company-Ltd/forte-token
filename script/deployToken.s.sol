// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/Wave.sol";

contract DeployToken is Script {

    uint privateKey;
    address ownerAddress;
    address minterAddress;

    Wave wave;


    function run() public {
        console.log("Deploy a Token");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        minterAddress = vm.envAddress("DEPLOYMENT_MINTER");

        vm.startBroadcast(privateKey);
        try this.deployToken(){
            console.log("Logic Success");
            console.log("WAVE_ADDRESS=%s", address(wave));
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
        }
        vm.stopBroadcast();
    }

    function deployToken() external {
        // 0x534d454c4c494e475f53414c5453 is bytes32("SMELLING_SALTS")
        wave = new Wave{salt: bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000)}(ownerAddress, minterAddress);
    }
}

