// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";

contract MintProtocolTokens is Script {

    uint256 appConfigAdminKey;
    address appConfigAdminAddress;
    address protocolTokenAddress;

    function run() public {
        /// switch to the config admin
        appConfigAdminKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        appConfigAdminAddress = vm.envAddress("DEPLOYMENT_OWNER");
        protocolTokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(appConfigAdminKey);
        ProtocolToken protocolToken = ProtocolToken(protocolTokenAddress);
        protocolToken.mint(vm.envAddress("MINT_TO"), vm.envUint("MINT_AMOUNT"));
        vm.stopBroadcast();

        console.log("Minted %s tokens to %s", protocolToken.balanceOf(vm.envAddress("MINT_TO")), vm.envAddress("MINT_TO"));
    }
}

