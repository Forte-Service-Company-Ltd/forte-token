// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {ProtocolToken} from "src/token/ProtocolToken.sol";
// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";

import {TestCommon} from "test/token/TestCommon.sol";

contract BridgeTokenTest is TestCommon {

    uint privateKey;
    address ownerAddress;
    address minterAddress;
    bytes32 tokenId;
    bytes32 salt;

    ProtocolToken wave;
    InterchainTokenService tokenService;

    function setUp() public {
        if (vm.envBool("FORK_TEST") == true) {
            privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
            ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
            minterAddress = vm.envAddress("DEPLOYMENT_MINTER");
            vm.createSelectFork("sepolia_chain");
            salt = bytes32(keccak256(abi.encode(vm.envString("SALT_STRING"))));

            tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));

            bytes32 expectedTokenId = tokenService.interchainTokenId(ownerAddress, salt);
            
            setUpTokenWithHandler();

            bytes memory ownerAddressBytes = abi.encodePacked(ownerAddress);
            bytes memory params = abi.encode(ownerAddressBytes, address(protocolTokenProxy));

            tokenId = tokenService.deployTokenManager(
                salt,
                "", 
                ITokenManagerType.TokenManagerType.LOCK_UNLOCK, 
                params,
                0
            );

            assertEq(tokenId, expectedTokenId);
        bytes32 tokenId2 = tokenService.deployTokenManager(
            salt, 
            "base-sepolia",
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK,
            params, 
            0.01 ether
        );

            assertEq(tokenId2, tokenId);

            switchToAppAdministrator();
            ProtocolToken(address(protocolTokenProxy)).mint(ownerAddress, 100 ether);
            vm.stopPrank();
        testDeployments = true;
        } else {
            testDeployments = false;
        }
    }

    function testSendTokenCrossChain() public ifDeploymentTestsEnabled {
        string memory destinationChain = "base-sepolia";
        bytes memory destinationAddress = abi.encodePacked(ownerAddress);
        uint amount = 1 ether; // 10^18

        vm.startPrank(ownerAddress);
        ProtocolToken(address(protocolTokenProxy)).approve(address(tokenService), amount);
        tokenService.interchainTransfer(
            tokenId,
            destinationChain,
            destinationAddress,
            amount,
            bytes(""),
            0.01 ether
        ); 
    }
}

