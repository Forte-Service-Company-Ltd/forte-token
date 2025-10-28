// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Script.sol";
import "src/token/ProtocolTokenv2.sol";
import "src/token/ProtocolTokenProxy.sol";
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
    uint256 minterAdminKey;
    address minterAdminAddress;
    address proxyOwnerAddress;

    function setUp() public {}

    function run() public {
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        vm.startBroadcast(privateKey);

        /// Create ERC20 Upgradeable logic contract
        ProtocolTokenv2 token = new ProtocolTokenv2{salt: keccak256(abi.encodePacked(vm.envString("SALT_STRING")))}();
        setENVAddress("LOGIC_ADDRESS", vm.toString(address(token)));
        vm.stopBroadcast();

    }


}
