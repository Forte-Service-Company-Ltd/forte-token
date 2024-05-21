// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 
import "test/token/TestArrays.sol";
import {DummyAMM} from "tronTest/client/token/TestTokenCommon.sol";

/**
 * @title ERC20 Upgradeable Fork Tests
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4 
 * @dev This is the fork tests for ERC20U protocol integration.

 * Test Command: 
 * Set env FORK_TEST variable to "true"
 * Export your RPC_URL for amoy test net 
 * forge test --ffi -vvv --match-path test/token/deployment/RuleProcessorIntegration.t.sol --fork-url $RPC_URL --fork-block-number 7598888
 */
contract ProtocolTokenProtocolIntegrationTest is TestCommon, TestArrays, DummyAMM {

    DummyAMM public tokenAmm;
    ProtocolToken public testToken; 
    ProtocolTokenProxy public testTokenProxy; 
    ProtocolERC20Pricing public erc20Pricer;
    ProtocolERC721Pricing public erc721Pricer;

    function setUp() public endWithStopPrank {
       // set blocktime as deployment block for rule processor so tests are from a clean state
       // Set Fork Test variable to true in env if running fork tests 
        if (vm.envBool("FORK_TEST") == true) {
            Blocktime = 7598888;
            switchToDeploymentOwner(); 
            superAdmin = address(0x7E97c19CA80Ba38D64c8C2e047694a11459C23bB); // old 0xc21B6Fd3ba77e6C76dB8f2Fd4C48DB1BA2B12085
            // set rule processor diamond address 
            ruleProcessorDiamond = RuleProcessorDiamond(payable(vm.envAddress("RULE_PROCESSOR_DIAMOND")));
            // set up app manager and handler address 
            appManager = AppManager(vm.envAddress("APP_MANAGER"));
            appManager.addAppAdministrator(appAdministrator);
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
            ProtocolToken(address(protocolTokenProxy)).initialize("Wave", "WAVE", address(appManager)); 
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
    /// all test function should use ifDeploymentTestsEnabled() modifier 

    function testERC20U_ForkTesting_IsSuperAdmin() public view ifDeploymentTestsEnabled {
        assertEq(appManager.isSuperAdmin(superAdmin), true);
        assertEq(appManager.isSuperAdmin(appAdministrator), false);
    }

    function testERC20U_ForkTesting_IsAppAdministrator_Negative() public view ifDeploymentTestsEnabled {
        assertEq(appManager.isAppAdministrator(user1), false);
    }

    function testERC20U_ForkTesting_IsAppAdministrator_Positive() public view ifDeploymentTestsEnabled {
        assertEq(appManager.isAppAdministrator(appAdministrator), true);
    }

    function testERC20U_ForkTesting_TestMinting_Positive() public ifDeploymentTestsEnabled {        
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
    }

    function testERC20U_ForkTesting_TestMinting_Negative() public ifDeploymentTestsEnabled {
        switchToUser(); 
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 0);
    }

    function testERC20U_ForkTesting_TestBurn_Positive() public ifDeploymentTestsEnabled {
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
        ProtocolToken(address(protocolTokenProxy)).burn(900);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 100);
    }

    function testERC20U_ForkTesting_TestBurn_Negative() public ifDeploymentTestsEnabled {
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).burn(9000);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
    }

    function testERC20U_ForkTesting_TestTransfers_Positive() public ifDeploymentTestsEnabled {
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 500);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 500);
    }

    function testERC20U_ForkTesting_TestTransfers_Negative() public ifDeploymentTestsEnabled {
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 5000);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function _mintToAdminAndUsers() internal {
        switchToAppAdministrator(); 
        //admin mint 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1000); 
        // user 1 mint 
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 1000);
        // user 2 mint 
        ProtocolToken(address(protocolTokenProxy)).mint(user2, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), 1000);
        // user 3 mint 
        ProtocolToken(address(protocolTokenProxy)).mint(user3, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user3), 1000);
        // user 4 mint 
        ProtocolToken(address(protocolTokenProxy)).mint(user4, 1000); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user4), 1000);
    }
    // Oracle Rule 
    function _addOracleRule() internal ifDeploymentTestsEnabled returns(uint32 approvedOracleId, uint32 deniedOracleId) {
        switchToRuleAdmin();
        uint32 approvedRuleId = RuleDataFacet(address(ruleProcessorDiamond)).addAccountApproveDenyOracle(address(appManager), 1, address(oracleApproved));
        uint32 deniedRuleId = RuleDataFacet(address(ruleProcessorDiamond)).addAccountApproveDenyOracle(address(appManager), 0, address(oracleDenied));
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessorDiamond)).getAccountApproveDenyOracle(approvedRuleId).oracleType, 1);
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessorDiamond)).getAccountApproveDenyOracle(deniedRuleId).oracleType, 0);
        return(approvedRuleId, deniedRuleId);
    }

    function testERC20U_ForkTesting_OracleRule_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 approveRuleId;
        uint32 deniedRuleId;
        (approveRuleId, deniedRuleId) = _addOracleRule();
        // set ruleId in handler 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BURN);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setAccountApproveDenyOracleId(actionTypes, approveRuleId);
        // add users to approved list 
        switchToAppAdministrator();
        address[] memory approvedList = new address[](4); 
        approvedList[0] = user1; 
        approvedList[1] = user2;
        approvedList[2] = user3;
        approvedList[3] = user4;
        oracleApproved.addToApprovedList(approvedList);
        // transfer to user 
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 1000);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), 2000);
    }

    function testERC20U_ForkTesting_OracleRule_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 approveRuleId;
        uint32 deniedRuleId;
        (approveRuleId, deniedRuleId) = _addOracleRule();
        // set ruleId in handler 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BURN);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setAccountApproveDenyOracleId(actionTypes, approveRuleId);
        // transfer to user fails since not on approved list 
        switchToUser();
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 1000);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), 1000);
    }

    // Account Min/Max Token Balance 
    function _addMinMaxTokenBalance() internal ifDeploymentTestsEnabled returns(uint32 ruleId) {
        switchToRuleAdmin();
        uint16[] memory periods;
        ruleId = TaggedRuleDataFacet(address(ruleProcessorDiamond)).addAccountMinMaxTokenBalance(address(appManager), createBytes32Array("testTag"), createUint256Array(10), createUint256Array(2000), periods, uint64(Blocktime));
        return ruleId;
    }
    function testERC20U_ForkTesting_MinMaxTokenBalance_Transfer_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToAppAdministrator(); 
        appManager.addTag(user1, "testTag");
        appManager.addTag(user2, "testTag");
        switchToRuleAdmin();
        uint32 ruleId = _addMinMaxTokenBalance(); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BUY, ActionTypes.BURN);
        ERC20TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 990); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), 1990);
    }

    function testERC20U_ForkTesting_MinMaxTokenBalance_Transfer_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToAppAdministrator(); 
        appManager.addTag(user1, "testTag");
        appManager.addTag(user2, "testTag");
        switchToRuleAdmin();
        uint32 ruleId = _addMinMaxTokenBalance(); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BUY, ActionTypes.BURN);
        ERC20TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToUser(); 
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 991); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), 1000);
    }

    function testERC20U_ForkTesting_MinMaxTokenBalance_Mint_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToAppAdministrator(); 
        appManager.addTag(user1, "testTag");
        switchToRuleAdmin();
        uint32 ruleId = _addMinMaxTokenBalance(); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BUY, ActionTypes.BURN);
        ERC20TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).burn(990); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 10);
    }

    function testERC20U_ForkTesting_MinMaxTokenBalance_Mint_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToAppAdministrator(); 
        appManager.addTag(user1, "testTag");
        switchToRuleAdmin();
        uint32 ruleId = _addMinMaxTokenBalance(); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BUY, ActionTypes.BURN);
        ERC20TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToUser(); 
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ProtocolToken(address(protocolTokenProxy)).burn(991); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 1000);
    }

    // Token Max Buy Sell Volume  
    function _addTokenMaxBuySellVolume(uint16 _percent) public ifDeploymentTestsEnabled returns(uint32 ruleId){
        switchToRuleAdmin();
        uint16 supplyPercentage = _percent;
        uint16 period = 24;
        uint256 _totalSupply = 1_000_000;
        ruleId = RuleDataFacet(address(ruleProcessorDiamond)).addTokenMaxBuySellVolume(address(appManager), supplyPercentage, period, _totalSupply, Blocktime);
        return ruleId;
    }

    function testERC20U_ForkTesting_TokenMaxBuySellVolume_Buy_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32[] memory ruleId = new uint32[](2);
        ruleId[0] = _addTokenMaxBuySellVolume(5000);
        ruleId[1] = _addTokenMaxBuySellVolume(5000);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        TradingRuleFacet(address(handlerDiamond)).setTokenMaxBuySellVolumeIdFull(actionTypes, ruleId);
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 500, 500, true); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 500);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 500);
    }

    function testERC20U_ForkTesting_TokenMaxBuySellVolume_Sell_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32[] memory ruleId = new uint32[](2);
        ruleId[0] = _addTokenMaxBuySellVolume(5000);
        ruleId[1] = _addTokenMaxBuySellVolume(5000);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        TradingRuleFacet(address(handlerDiamond)).setTokenMaxBuySellVolumeIdFull(actionTypes, ruleId);
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 500, 500, false); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1500);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 0);
    }

    function testERC20U_ForkTesting_TokenMaxBuySellVolume_Buy_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32[] memory ruleId = new uint32[](2);
        ruleId[0] = _addTokenMaxBuySellVolume(10);
        ruleId[1] = _addTokenMaxBuySellVolume(10);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        TradingRuleFacet(address(handlerDiamond)).setTokenMaxBuySellVolumeIdFull(actionTypes, ruleId);
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 500, 500, true); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 500);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 500);

        ProtocolToken(address(testTokenProxy)).mint(user1, 5000); 
        switchToUser(); 
        ProtocolToken(address(testTokenProxy)).approve(address(tokenAmm), 10000); 
        ProtocolToken(address(protocolTokenProxy)).approve(address(tokenAmm), 10000);
        vm.expectRevert(abi.encodeWithSignature("OverMaxVolume()"));
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 1000, 1000, true);

        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 1000);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(user1), 5000);
    }

    function testERC20U_ForkTesting_TokenMaxBuySellVolume_Sell_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32[] memory ruleId = new uint32[](2);
        ruleId[0] = _addTokenMaxBuySellVolume(10);
        ruleId[1] = _addTokenMaxBuySellVolume(10);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        TradingRuleFacet(address(handlerDiamond)).setTokenMaxBuySellVolumeIdFull(actionTypes, ruleId);
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 500, 500, false); 
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), 1500);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 0);

        ProtocolToken(address(testTokenProxy)).mint(user1, 5000); 
        switchToUser(); 
        ProtocolToken(address(testTokenProxy)).approve(address(tokenAmm), 10000); 
        ProtocolToken(address(protocolTokenProxy)).approve(address(tokenAmm), 10000);
        vm.expectRevert(abi.encodeWithSignature("OverMaxVolume()"));
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 1000, 1000, false);

        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 1000);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(user1), 5000);

    }

    // Token Max Trading Volume 
    function _addTokenMaxTradingVolume(uint24 max) internal returns (uint32 ruleId) {
        switchToRuleAdmin();
        uint16 period = 24;
        uint256 _totalSupply = 1_000_000;
        ruleId = RuleDataFacet(address(ruleProcessorDiamond)).addTokenMaxTradingVolume(address(appManager), max, period, Blocktime, _totalSupply);
        return ruleId;
    }

    function testERC20U_ForkTesting_AddMaxTradingVolume_Transfers_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(100); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 1000);
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000);

    }

    function testERC20U_ForkTesting_AddMaxTradingVolume_Transfers_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(10); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 100);
        switchToAppAdministrator(); 
        vm.expectRevert(abi.encodeWithSignature("OverMaxTradingVolume()"));
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000);

    }

    function testERC20U_ForkTesting_MaxTradingVolume_Buy_Positive() public ifDeploymentTestsEnabled {
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(1000); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToAppAdministrator(); 
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 50, 50, false);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 450);
    }

    function testERC20U_ForkTesting_MaxTradingVolume_Sell_Positive() public ifDeploymentTestsEnabled {
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(1000); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToAppAdministrator(); 
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 50, 50, true);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 550);
    }

    function testERC20U_ForkTesting_MaxTradingVolume_Buy_Negative() public ifDeploymentTestsEnabled {
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(10); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToAppAdministrator(); 
        vm.expectRevert(abi.encodeWithSignature("OverMaxTradingVolume()"));
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 500, 1000, false);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 500);
    }

    function testERC20U_ForkTesting_MaxTradingVolume_Sell_Negative() public ifDeploymentTestsEnabled {
        tokenAmm = setUpAMM();
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 500);
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addTokenMaxTradingVolume(10); 
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT);
        ERC20NonTaggedRuleFacet(address(handlerDiamond)).setTokenMaxTradingVolumeId(actionTypes, ruleId);
        switchToAppAdministrator(); 
        vm.expectRevert(abi.encodeWithSignature("OverMaxTradingVolume()"));
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 1000, 1000, true);
        assertEq(ProtocolToken(address(testTokenProxy)).balanceOf(appAdministrator), 500);
    }

    function _addAccountMaxTxValueByRiskRule() internal returns (uint32 ruleId) {
        switchToRuleAdmin();
        ruleId = AppRuleDataFacet(address(ruleProcessorDiamond)).addAccountMaxTxValueByRiskScore(address(appManager), createUint48Array(10000, 1000, 100), createUint8Array(25, 50, 75), 0, Blocktime);
        return ruleId;
    }

    function testERC20U_ForkTesting_AccountMaxTxValueByRisk_Transfer_Positive() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        uint32 ruleId = _addAccountMaxTxValueByRiskRule();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BURN);
        appHandler.setAccountMaxTxValueByRiskScoreId(actionTypes, ruleId);
        switchToRiskAdmin(); 
        appManager.addRiskScore(user1, 25);
        appManager.addRiskScore(user2, 50);
        appManager.addRiskScore(user3, 75);
        switchToUser3(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 1000); 

        switchToUser2(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000);

        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user3, 100);
    }

    function testERC20U_ForkTesting_AccountMaxTxValueByRisk_Transfer_Negative() public ifDeploymentTestsEnabled {
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 1000 * (1 * (10 ** 18)));
        ProtocolToken(address(protocolTokenProxy)).mint(user2, 1000 * (1 * (10 ** 18)));
        ProtocolToken(address(protocolTokenProxy)).mint(user3, 1000 * (1 * (10 ** 18)));
        switchToRuleAdmin();
        uint32 ruleId = _addAccountMaxTxValueByRiskRule();
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BUY, ActionTypes.SELL, ActionTypes.MINT, ActionTypes.BURN);
        appHandler.setAccountMaxTxValueByRiskScoreId(actionTypes, ruleId);
        switchToRiskAdmin(); 
        appManager.addRiskScore(user1, 25);
        appManager.addRiskScore(user2, 50);
        appManager.addRiskScore(user3, 75);
        switchToUser3(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 10 * (1 * (10 ** 18))); 

        switchToUser2(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000 * (1 * (10 ** 18)));

        switchToUser(); 
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 75, 100000000000000000000));
        ProtocolToken(address(protocolTokenProxy)).transfer(user3, 500 * (1 * (10 ** 18)));
    }

    function testERC20U_ForkTesting_PauseRules_Transfer_Negative() public ifDeploymentTestsEnabled {
        _mintToAdminAndUsers();
        switchToRuleAdmin();
        appManager.addPauseRule(Blocktime + 10, Blocktime + 50); 
        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user3, 500);
        vm.warp(Blocktime + 25);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 10, Blocktime + 50));
        ProtocolToken(address(protocolTokenProxy)).transfer(user3, 500);
    }

    function setUpAMM() internal returns (DummyAMM){
        switchToAppAdministrator(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 1_000_000_000); 
        tokenAmm = new DummyAMM(); 
        ProtocolToken(address(protocolTokenProxy)).approve(address(tokenAmm), 1000000); 

        // create second token for AMM swaps 
        testToken = _deployERC20Upgradeable(); 
        // deploy proxy 
        testTokenProxy = _deployERC20UpgradeableProxy(address(testToken), proxyOwner); 
        
        switchToAppAdministrator(); 
        ProtocolToken(address(testTokenProxy)).initialize("Test", "TEST", address(appManager)); 
        assetHandlerTest = new DummyAssetHandler();
        ProtocolToken(address(testTokenProxy)).connectHandlerToToken(address(assetHandlerTest)); 
        appManager.registerToken("TEST", address(testTokenProxy));
        ProtocolToken(address(testTokenProxy)).mint(appAdministrator, 1_000_000_000);
        ProtocolToken(address(testTokenProxy)).approve(address(tokenAmm), 1000000);
        /// fund the amm with 
        ProtocolToken(address(testTokenProxy)).transfer(address(tokenAmm), 1_000_000_000);
        ProtocolToken(address(protocolTokenProxy)).transfer(address(tokenAmm), 1_000_000_000);
        /// User 1 gives approvals 
        switchToUser(); 
        ProtocolToken(address(testTokenProxy)).approve(address(tokenAmm), 1000000);
        ProtocolToken(address(protocolTokenProxy)).approve(address(tokenAmm), 1000000);

        return tokenAmm;
    }
    function switchToDeploymentOwner() internal {
        vm.stopPrank(); 
        vm.startPrank(0x7E97c19CA80Ba38D64c8C2e047694a11459C23bB); 
    }
}