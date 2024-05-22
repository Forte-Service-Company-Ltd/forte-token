// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "src/token/Wave.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";

contract BridgeTokenTest is Test {

    uint privateKey;
    address ownerAddress;
    address minterAddress;

    Wave wave;
    InterchainTokenService tokenService;

    function setUp() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        minterAddress = vm.envAddress("DEPLOYMENT_MINTER");
        vm.createSelectFork("sepolia_chain");
        wave = new Wave{salt: bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000)}(ownerAddress, minterAddress);
        tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));

        bytes32 tokenId = tokenService.deployTokenManager(
            bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000),
            "", 
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK, 
            abi.encode(ownerAddress, address(wave)),
            .01 ether
        );

        console.log("TOKEN_ID=");
        console.logBytes32(tokenId);
    }

    function testSendTokenCrossChain() public {
        bytes32 tokenId = vm.envBytes32("TOKEN_ID");
        string memory destinationChain = vm.envString("DESTINATION_CHAIN");
        bytes memory destinationAddress = abi.encode(vm.envAddress("DESTINATION_ADDRESS"));
        uint amount = vm.envUint("AMOUNT");

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

