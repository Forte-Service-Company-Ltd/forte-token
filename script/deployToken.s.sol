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
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
        }
        vm.stopBroadcast();
    }

    function deployToken() external {
        console.log("deployToken");
        wave = new Wave(ownerAddress, minterAddress);
    }
}