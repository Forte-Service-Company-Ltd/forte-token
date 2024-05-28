// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "src/token/Wave2.sol";

// note: needed to avoid conflict with ERC20 interface in OpenZeppelin
import {InterchainTokenService} from "interchain-token-service/InterchainTokenService.sol";
import {ITokenManagerType} from "interchain-token-service/interfaces/ITokenManagerType.sol";
import {TokenManagerDeployer} from "interchain-token-service/utils/TokenManagerDeployer.sol";
import {TokenHandler} from "interchain-token-service/TokenHandler.sol";
import {InterchainTokenDeployer} from "interchain-token-service/utils/InterchainTokenDeployer.sol";
import {InterchainToken} from "interchain-token-service/interchain-token/InterchainToken.sol";
import {TokenManager} from "interchain-token-service/token-manager/TokenManager.sol";

import {Create3Deployer} from "axelar-gmp-sdk-solidity/deploy/Create3Deployer.sol";

contract BridgeTokenTest is Test {

    uint privateKey;
    address ownerAddress;
    address minterAddress;
    bytes32 tokenId;

    Wave2 wave;
    InterchainTokenService tokenService;

    function setUp() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        minterAddress = vm.envAddress("DEPLOYMENT_MINTER");
        vm.createSelectFork("sepolia_chain");
        bytes32 salt = bytes32(0x534d454c4c494e475f53414c5453000000000000000000000000000000000000);

        tokenService = InterchainTokenService(vm.envAddress("INTERCHAIN_TOKEN_SERVICE"));

        // trying to set up with the ability to create logging
        // Create3Deployer create3Deployer = new Create3Deployer();
        // address itsPredictedAddress = create3Deployer.deployedAddress(type(InterchainTokenService).creationCode, ownerAddress, salt);
        // console.log("itsPredictedAddress: ", itsPredictedAddress);
        // InterchainToken interchainToken = new InterchainToken(itsPredictedAddress);
        // tokenService = new InterchainTokenService(
        //     address(new TokenManagerDeployer()),
        //     address(new InterchainTokenDeployer(address(interchainToken))),
        //     address(vm.envAddress("ETH_SEPOLIA_AXELAR_GATEWAY")),
        //     address(0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6),
        //     address(0x83a93500d23Fbc3e82B410aD07A6a9F7A0670D66),
        //     "ethereum-sepolia",
        //     address(new TokenManager(itsPredictedAddress)),
        //     address(new TokenHandler(vm.envAddress("ETH_SEPOLIA_AXELAR_GATEWAY")))
        // );
        // console.log("expected tokenID: ");

        bytes32 expectedTokenId = tokenService.interchainTokenId(ownerAddress, salt);
        wave = new Wave2{salt: salt}("Wave2", "WTK", 18, address(tokenService), expectedTokenId);
        console.logBytes32(expectedTokenId);
        
        console.log("expected token manager address: ", tokenService.tokenManagerAddress(expectedTokenId));
        bytes memory ownerAddressBytes = abi.encodePacked(ownerAddress);
        bytes memory params = abi.encode(ownerAddressBytes, address(wave));
        console.logBytes(params);
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

        console.log("TOKEN_ID=");
        console.logBytes32(tokenId);
        wave.mint(ownerAddress, 100 ether);
    }

    function testSendTokenCrossChain() public {
        string memory destinationChain = "base-sepolia"; //vm.envString("DESTINATION_CHAIN")
        bytes memory destinationAddress = abi.encodePacked(ownerAddress); //vm.envBytes("DESTINATION_ADDRESS");
        uint amount = 1 ether; //vm.envUint("AMOUNT");

        vm.startPrank(ownerAddress);
        wave.approve(address(tokenService), amount);
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

