// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/foreignCall/AllowList.sol";
import "script/deployUtil.s.sol";

/**
 * @title Deploy AllowList
 * @author @ShaneDuncan602 
 * @dev This script will deploy an allow list contract to be used with Forte Rules Engine.
 * @notice Requires .env variables to be set with correct addresses 
 */

contract DeployAllowList is DeployScriptUtil {
    uint256 deployerPrivateKey;
    address deployerAddress;
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    function setUp() public {}

    function run() public {
        deployerPrivateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        deployerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(deployerPrivateKey);
        
        /// Create AllowList
        AllowList allowList = new AllowList(deployerAddress);

        setENVAddress("ALLOWLIST_ADDRESS", vm.toString(address(allowList)));
        vm.stopBroadcast();
    }
}

