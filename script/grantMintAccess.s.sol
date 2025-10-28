// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Script.sol";
import "src/token/ProtocolToken.sol";

/**
 * @title Mint Protocol Tokens Script
 * @author @ShaneDuncan602 @VoR0220 @Palmerg4 @TJ-Everett
 * @dev This script will grant mint role to the token manager on a foreign address allowing them to mint and burn to transfer tokens.
 * @notice This grants the mint role to the token manager on a foreign address allowing them to mint and burn to transfer tokens.
 * forge script script/grantMintAccess.s.sol --ffi --rpc-url $FOREIGN_CHAIN_RPC_URL --broadcast -vvvv
 */

contract GrantMintAccess is Script {
    uint256 appConfigAdminKey;
    address appConfigAdminAddress;
    address tokenManagerAddress;

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");

    function run() public {
        appConfigAdminKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        appConfigAdminAddress = vm.envAddress("DEPLOYMENT_OWNER");
        tokenManagerAddress = vm.envAddress("TOKEN_MANAGER_ADDRESS");

        vm.startBroadcast(appConfigAdminKey);

        ProtocolToken token = ProtocolToken(vm.envAddress("TOKEN_ADDRESS"));
        token.grantRole(MINTER_ROLE, tokenManagerAddress);

        vm.stopBroadcast();
    }
}