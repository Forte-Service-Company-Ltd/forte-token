// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "src/token/Wave.sol";
import "interchain-token-service/InterchainTokenService.sol";

contract SendTokenCrossChain is Script {

    uint privateKey;
    address ownerAddress;
    bytes32 tokenId;

    string destinationChain;
    bytes destinationAddress;
    uint amount;

    Wave wave;
    InterchainTokenService tokenService;

    function run() public {
        console.log("Send Token Cross Chain");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        tokenId = vm.envBytes32("TOKEN_ID");
        destinationChain = vm.envString("DESTINATION_CHAIN");
        destinationAddress = abi.encode(vm.envAddress("DESTINATION_ADDRESS"));
        amount = vm.envUint("AMOUNT");

        // uint gas amount = // do something here to call the axelar gas service to get a realistic number

        vm.startBroadcast(privateKey);
        try this.sendTokenCrossChain(){
            console.log("Logic Success");
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
        }
        vm.stopBroadcast();
    }

    function sendTokenCrossChain() external {
        console.log("sendTokenCrossChain");
        tokenService.interchainTransfer(
            tokenId,
            destinationChain,
            destinationAddress,
            amount,
            bytes(""),
            .01 ether
        ); 
    }
}