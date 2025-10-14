// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "script/deployUtil.s.sol";

/**
 * @title Deploy FOR Token Logic Contract
 * @author @ShaneDuncan602 
 * @dev This script will deploy an ERC20 Upgradeable fungible token logic contract and upgrade the existing proxy to use it.
 * @notice Requires .env variables to be set with correct addresses
 */

contract DeployLogicContract is DeployScriptUtil {
    uint256 privateKey;
    address ownerAddress;
    address freAddress;
    address tams;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        freAddress = vm.envAddress("FORTE_RULES_ENGINE_ADDRESS");
        vm.startBroadcast(privateKey);

        /// Propose TAMS as new policy Admin
        IProposeAdmin(freAddress).proposeNewPolicyAdmin(tams,vm.envUint("POLICY_ID"));
        vm.stopBroadcast();

    }


}

interface IProposeAdmin {
    function proposeNewPolicyAdmin(address newPolicyAdmin, uint256 policyId) external;
}
