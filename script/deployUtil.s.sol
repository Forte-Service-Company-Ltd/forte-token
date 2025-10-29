// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/src/Script.sol";

contract DeployScriptUtil is Script {
    function setENVAddress(string memory variable, string memory value) internal {
        /// we clear the value of the RULE_PROCESSOR_DIAMOND in the env file
        string[] memory setENVInput = new string[](4);
        setENVInput[0] = "python3";
        setENVInput[1] = "script/python/set_env_address.py";
        setENVInput[2] = variable;
        setENVInput[3] = value;
        vm.ffi(setENVInput);
    }
}