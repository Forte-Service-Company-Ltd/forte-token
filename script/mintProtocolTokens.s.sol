// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/token/ProtocolToken.sol";

/**
 * @title Mint Protocol Tokens Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will mint protocol tokens to the specified address
 * @notice This mints a specified amount to a specific address. This is particularly useful to set up the foreign chain token manager for bridging.
 * forge script script/mintProtocolTokens.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract MintProtocolTokens is Script {

    uint256 appConfigAdminKey;
    address appConfigAdminAddress;
    address protocolTokenAddress;

    function run() public {
        /// switch to the config admin
        appConfigAdminKey = vm.envUint("MINTER_ADMIN_KEY");
        appConfigAdminAddress = vm.envAddress("MINTER_ADMIN");
        protocolTokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(appConfigAdminKey);
        ProtocolToken protocolToken = ProtocolToken(protocolTokenAddress);
        protocolToken.mint(vm.envAddress("MINT_TO"), vm.envUint("MINT_AMOUNT"));
        vm.stopBroadcast();

        console.log("Minted %s tokens to %s", protocolToken.balanceOf(vm.envAddress("MINT_TO")), vm.envAddress("MINT_TO"));
    }
}

