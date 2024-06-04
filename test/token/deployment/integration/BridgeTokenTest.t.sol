// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "src/token/Wave.sol";
import {ProtocolToken} from "src/token/ProtocolToken.sol";

import {AppManager} from "tron/client/application/AppManager.sol";
import {RuleProcessorDiamond, RuleProcessorDiamondArgs, FacetCut} from "tron/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {ProtocolApplicationHandler} from "tron/client/application/ProtocolApplicationHandler.sol";
import {ERC20HandlerMainFacet} from "tron/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";

// note: these were used to put logs into the ITS and be able to track and debug errors along the way
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";
import {TokenManagerDeployer} from "interchain-token-service/utils/TokenManagerDeployer.sol";
import {TokenHandler} from "interchain-token-service/TokenHandler.sol";
import {InterchainTokenDeployer} from "interchain-token-service/utils/InterchainTokenDeployer.sol";
import {InterchainToken} from "interchain-token-service/interchain-token/InterchainToken.sol";
import {TokenManager} from "interchain-token-service/token-manager/TokenManager.sol";

import {Create3Deployer} from "axelar-gmp-sdk-solidity/deploy/Create3Deployer.sol";

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


        tokenService.deployTokenManager(
            salt, 
            "base-sepolia",
            ITokenManagerType.TokenManagerType.LOCK_UNLOCK,
            params, 
            0.01 ether
        );

        switchToAppAdministrator();
        ProtocolToken(address(protocolTokenProxy)).mint(ownerAddress, 100 ether);
        vm.stopPrank();
    }

    function testSendTokenCrossChain() public {
        string memory destinationChain = "base-sepolia";
        bytes memory destinationAddress = abi.encodePacked(ownerAddress);

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

