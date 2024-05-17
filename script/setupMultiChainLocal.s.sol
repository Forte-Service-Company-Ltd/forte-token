// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "axelar-gmp-sdk-solidity/deploy/Create3Deployer.sol";
import "axelar-gmp-sdk-solidity/interfaces/IAxelarGMPGatewayWithToken.sol";

contract SetupMultiChainLocal is Script {

    uint privateKey;
    address ownerAddress;
    Create3Deployer create3Deployer;
    address tokenAddr;
    IAxelarGMPGatewayWithToken gateway;

    function run() public {
        console.log("SetupMultiChain");
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        
        console.log("privateKey: %s", privateKey);
        console.log("ownerAddress: %s", ownerAddress);

        vm.startBroadcast();
        try this.mainScriptLogic(){
            console.log("Logic Success");
        } catch Error(string memory reason) {
            console.log("Error: %s", reason);
            _tearDownMultiChainSpinup();
        }
        vm.stopBroadcast();
    }

    function mainScriptLogic() external {
        console.log("mainScriptLogic");
        _buildMultiChainSpinup(); // may not be necessary, might want to instead use direct testnet rpcs
        _deployMultiChain();
    }

    function _deployMultiChain() internal {
        vm.createSelectFork(vm.rpcUrl("local_chain_1"));
        _deployCreate3();
        _deployAxelarGateway("AMOY_AXELAR_GATEWAY");
        _deployToken();
        vm.createSelectFork(vm.rpcUrl("local_chain_2"));
        _deployCreate3();
        _deployAxelarGateway("ETH_SEPOLIA_AXELAR_GATEWAY");
        _deployToken();
    }

    function _deployCreate3() internal {
        create3Deployer = new Create3Deployer();
    }

    function _deployAxelarGateway(string memory env) internal {
        gateway = IAxelarGMPGatewayWithToken(vm.envAddress(env));
    }

    function _deployToken() internal {
        tokenAddr = create3Deployer.deploy(token.bytecode, keccak256("SMELLING_SALTS"));
    }

    function _buildMultiChainSpinup() internal {
        string[] memory commnds = new string[](10);
        commnds[0] = "anvil";
        commnds[1] = ">";
        commnds[2] = "anvil-output.log";
        commnds[3] = "2>&1";
        commnds[4] = "&";
        commnds[5] = "anvil";
        commnds[6] = "&";
        commnds[7] = "anvil";
        commnds[8] = "-p";
        commnds[9] = "8546";
        vm.ffi(commnds);
    }

    function _tearDownMultiChainSpinup() internal {
        string[] memory commnds = new string[](6);
        commnds[0] = "lsof";
        commnds[1] = "-t";
        commnds[2] = "-i";
        commnds[3] = "tcp:8545";
        commnds[4] = "|";
        commnds[5] = "xargs";
        commnds[6] = "kill";
        commnds[7] = "&&";
        commnds[8] = "lsof";
        commnds[9] = "-t";
        commnds[10] = "-i";
        commnds[11] = "tcp:8546";
        commnds[12] = "|";
        commnds[13] = "xargs";
        commnds[14] = "kill";
        vm.ffi(commnds);
    }
}

