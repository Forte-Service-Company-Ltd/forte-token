// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {ProtocolToken} from "src/token/ProtocolToken.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";


/**
 * @title Send Protocol Tokens Cross Chain Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will send protocol tokens to the specified address on a foreign chain
 * @notice This is used to send tokens to the foreign chain token manager for bridging.
 * forge script script/sendTokenCrossChain.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract SendTokenCrossChain is Script {

    uint privateKey;
    address ownerAddress;
    bytes32 tokenId;

    string destinationChain;
    bytes destinationAddress;
    uint amount;

    InterchainTokenService tokenService;

    function run() public {
        console.log("Send Token Cross Chain");
        privateKey = vm.envUint("SENDER_KEY");
        ownerAddress = vm.envAddress("SENDER_ADDRESS");
        tokenId = vm.envBytes32("TOKEN_ID");
        destinationChain = vm.envString("DESTINATION_CHAIN");
        destinationAddress = abi.encodePacked(vm.envAddress("DESTINATION_ADDRESS"));
        tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));
        amount = vm.envUint("SEND_AMOUNT");

        vm.startBroadcast(privateKey);
        
        ProtocolToken For = ProtocolToken(vm.envAddress("TOKEN_ADDRESS"));
        
        For.approve(address(tokenService), amount);
        
        tokenService.interchainTransfer(
            tokenId,
            destinationChain,
            destinationAddress,
            amount,
            bytes(""),
            0.01 ether
        );

        vm.stopBroadcast();
    }
}
