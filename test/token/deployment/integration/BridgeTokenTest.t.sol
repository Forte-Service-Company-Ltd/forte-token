// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "src/token/Wave.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";
import {TokenManagerDeployer} from "interchain-token-service/utils/TokenManagerDeployer.sol";

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

        // trying to set up with the ability to create logging

        tokenService = new InterchainTokenService(
            address(new TokenManagerDeployer()),
            address(0x58667c5f134420Bf6904C7dD01fDDcB4Fea3a760),
            address(0xe432150cce91c13a887f7D836923d5597adD8E31),
            address(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6),
            address(0x83a93500d23Fbc3e82B410aD07A6a9F7A0670D66),
            "ethereum-sepolia",
            address(0x81a0545091864617E7037171FdfcBbdCFE3aeb23),
            address(0x07715674F74c560200c7C95430673180812fCE73)
        );
        console.log("expected tokenID: ");
        bytes32 expectedTokenId = tokenService.interchainTokenId(ownerAddress, bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000));
        console.logBytes32(expectedTokenId);
        
        console.log("expected token manager address: ", tokenService.tokenManagerAddress(expectedTokenId));

        bytes32 tokenId = tokenService.deployTokenManager(
            bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000),
            "", 
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK, 
            abi.encode(ownerAddress, address(wave)),
            .009 ether
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

