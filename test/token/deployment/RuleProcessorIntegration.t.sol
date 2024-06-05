// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 
import "test/token/TestArrays.sol";
import "test/token/ERC20UCommonTests.t.sol";

/**
 * @title ERC20 Upgradeable Fork Tests
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4 
 * @dev This is the fork tests for ERC20U protocol integration.

 * Test Command: 
 * Set env FORK_TEST variable to "true"
 * Set your AMOY_RPC_URL for amoy test net 
 * Run command forge test --ffi --fork-url $RPC_URL
 */
contract ProtocolTokenProtocolIntegrationTest is TestCommon, TestArrays, DummyAMM, ERC20UCommonTests {
    function setUp() public endWithStopPrank {
       // set blocktime as deployment block for rule processor so tests are from a clean state
       // Set Fork Test variable to true in env if running fork tests 
        if (vm.envBool("FORK_TEST") == true) {
            vm.createSelectFork(vm.envString("AMOY_RPC_URL"));
            superAdmin = vm.envAddress("AMOY_DEPLOYMENT_OWNER");
            vm.stopPrank(); 
            vm.startPrank(vm.envAddress("AMOY_DEPLOYMENT_OWNER")); 
            // set rule processor diamond address 
            ruleProcessorDiamond = RuleProcessorDiamond(payable(vm.envAddress("RULE_PROCESSOR_DIAMOND")));
            // set up app manager and handler address 
            appManager = AppManager(vm.envAddress("APP_MANAGER"));
            appManager.addAppAdministrator(appAdministrator);
            appManager.addRuleAdministrator(ruleAdmin);
            appHandler = ProtocolApplicationHandler(vm.envAddress("APP_HANDLER"));
            appManager.setNewApplicationHandlerAddress(vm.envAddress("APP_HANDLER"));
            // set asset handler diamond address 
            vm.warp(Blocktime);
            handlerDiamond = _createERC20HandlerDiamond();
            // deploy token and proxy 
            protocolToken = _deployERC20Upgradeable(); 
            // deploy proxy 
            protocolTokenProxy = _deployERC20UpgradeableProxy(address(protocolToken), proxyOwner); 
            ERC20HandlerMainFacet(address(handlerDiamond)).initialize(address(ruleProcessorDiamond), address(appManager), address(protocolTokenProxy));
            switchToAppAdministrator(); 
            ProtocolToken(address(protocolTokenProxy)).initialize("Wave", "WAVE", appAdministrator); 
            ProtocolToken(address(protocolTokenProxy)).grantRole(MINTER_ROLE, appAdministrator);
            ProtocolToken(address(protocolTokenProxy)).connectHandlerToToken(address(handlerDiamond)); 
            appManager.registerToken("WAVE", address(protocolTokenProxy));

            oracleApproved = new OracleApproved();
            oracleDenied = new OracleDenied();

            erc20Pricer = new ProtocolERC20Pricing();
            erc20Pricer.setSingleTokenPrice(address(protocolTokenProxy), 1 * (10 ** 18));
            erc721Pricer = new ProtocolERC721Pricing();
            switchToRuleAdmin();
            appHandler.setERC20PricingAddress(address(erc20Pricer)); 
            appHandler.setNFTPricingAddress(address(erc721Pricer)); 
            testDeployments = true;
        } else {
            testDeployments = false;
        }
    }
}
