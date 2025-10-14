// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "script/deployUtil.s.sol";
import "forte-rules-engine/engine/ForteRulesEngine.sol";

/**
 * @title Create Policy for FOR Token
 * @author @ShaneDuncan602 
 * @dev This script will create the policy for FOR Token
 * @notice Requires .env variables to be set with correct addresses 
 */

contract CreatePolicy is DeployScriptUtil {
    ForteRulesEngine red;
    address tokenAdmin;
    uint256 tokenAdminPrivateKey;
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    function setUp() public {}

    function run() public {
        // red = ForteRulesEngine(vm.envAddress("FORTE_RULES_ENGINE_ADDRESS"));
        // tokenAdmin = vm.envAddress("TAMS");
        // tokenAdminPrivateKey = vm.envUint("TAMS_PRIVATE_KEY");
        // vm.startBroadcast(tokenAdminPrivateKey);

        // // Create the policy
        // createForTokenPolicy();

        // vm.stopBroadcast();
    }

    function createForTokenPolicy() internal{}
    
}
