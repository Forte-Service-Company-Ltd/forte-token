// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Script.sol";
import "src/foreignCall/AllowList.sol";
import "script/deployUtil.s.sol";

/**
 * @title Load AllowList
 * @author @ShaneDuncan602 
 * @dev This script will load an allow list into the Allow List contract
 * @notice Requires .env variables to be set with correct addresses
 */

contract LoadAllowList is DeployScriptUtil {
    uint256 deployerPrivateKey;
    address deployerAddress;
    address allowListAddress;
    address tokenAdmin;
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    function setUp() public {}

    function run() public {
        deployerPrivateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        deployerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        tokenAdmin = vm.envAddress("TAMS");
        allowListAddress = vm.envAddress("ALLOWLIST_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);

        AllowList allowList = AllowList(allowListAddress);
        // address[] memory allowedAddresses = parseCsv(vm.envString("ALLOWLIST"));
        // allowList.isAllowed(allowListAddress);
        allowList.allowBatch(parseCsv(vm.envString("ALLOWLIST")));
        allowList.transferOwnership(tokenAdmin);
        vm.stopBroadcast();
    }

    function parseCsv(string memory csv) internal pure returns (address[] memory) {
        bytes memory b = bytes(csv);
        uint256 count = 1;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == ",") count++;
        }

        address[] memory result = new address[](count);
        uint256 start = 0;
        uint256 idx = 0;
        for (uint256 i = 0; i <= b.length; i++) {
            if (i == b.length || b[i] == ",") {
                // extract substring
                bytes memory slice = new bytes(i - start);
                for (uint256 j = 0; j < slice.length; j++) {
                    slice[j] = b[start + j];
                }
                start = i + 1;

                // convert substring to address
                result[idx] = parseAddress(string(slice));
                idx++;
            }
        }

        return result;
    }

    function parseAddress(string memory s) internal pure returns (address) {
        bytes memory strBytes = bytes(s);
        require(strBytes.length == 42, "invalid address length"); // "0x" + 40 hex chars
        uint160 addr = 0;
        for (uint256 i = 2; i < 42; i++) {
            uint8 b = uint8(strBytes[i]);
            uint8 val;
            if (b >= 48 && b <= 57) val = b - 48;          // '0' - '9'
            else if (b >= 65 && b <= 70) val = b - 55;     // 'A' - 'F'
            else if (b >= 97 && b <= 102) val = b - 87;    // 'a' - 'f'
            else revert("invalid hex char");
            addr = (addr << 4) | uint160(val);
        }
        return address(addr);
    }
}
