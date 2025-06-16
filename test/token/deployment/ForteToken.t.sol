// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol";
import "test/token/TestArrays.sol";
import "test/token/ERC20UCommonTests.t.sol";

/**
 * @title Forte Token Deployent Test
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4 
 * @dev This is the Specific Test of Forte Token Deployment

 * Test Command: 
 * Set ETH_RPC_URL to the deployed chain
 * Run command forge test --fork-url $ETH_RPC_URL
 */
contract ForteTokenTest is TestCommon {
    address TREASURY_1;
    address TREASURY_2;
    address RULE_ADMIN;
    address APP_ADMIN;
    address MINT_ADMIN;
    address PROXY_OWNER;
    bool SKIP_FORTE_TOKEN_TESTS = vm.envBool("SKIP_FORTE_TOKEN_TESTS");
    address USER_1;
    address USER_2;
    address payable tokenAddress;
    uint256 constant MINT_AMOUNT = 1_000_000_000 * 10E18;

    function setUp() public endWithStopPrank {
        // load env variables
        SKIP_FORTE_TOKEN_TESTS = vm.envBool("SKIP_FORTE_TOKEN_TESTS");
        if (!SKIP_FORTE_TOKEN_TESTS){
            TREASURY_1 = vm.envAddress("FRE_TREASURY_1_ADMIN");
            TREASURY_2 = vm.envAddress("FRE_TREASURY_2_ADMIN");
            RULE_ADMIN = vm.envAddress("FRE_RULE_ADMIN");
            APP_ADMIN = vm.envAddress("FRE_APP_ADMIN");
            MINT_ADMIN = vm.envAddress("MINTER_ADMIN");
            PROXY_OWNER = vm.envAddress("PROXY_OWNER");
            USER_1 = address(0xEf485b7F98650a9a545D8E92FAcCf57Fbf4474b6);
            USER_2 = address(0xd7770256590771b9f92c3Ae86AB922f20A6ad02e);
            // Load the FRE processor
            ruleProcessorDiamond = RuleProcessorDiamond(
                payable(vm.envAddress("RULE_PROCESSOR_DIAMOND"))
            );
            // Load the AppManager
            appManager = AppManager(payable(vm.envAddress("APPLICATION_APP_MANAGER")));
            vm.startPrank(RULE_ADMIN);
            // Load the token proxy
            tokenAddress = payable(vm.envAddress("TOKEN_ADDRESS"));
            protocolTokenProxy = ProtocolTokenProxy(tokenAddress);

            vm.stopPrank();
            // Load the token handler
            handlerDiamond = HandlerDiamond(
                payable(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS"))
            );
            vm.startPrank(TREASURY_1);
            ProtocolToken(tokenAddress).mint(TREASURY_1, MINT_AMOUNT);
            vm.warp(block.timestamp+100);
        }
    }

    // Make sure that the treasury accounts may transfer
    function testTransferPositive() public ifForteTestsEnabled {
        vm.skip(SKIP_FORTE_TOKEN_TESTS);
        vm.startPrank(TREASURY_1);
        ProtocolToken(tokenAddress).transfer(USER_1, 1);
        assertEq(ProtocolToken(tokenAddress).balanceOf(USER_1), 1);
    }

    // Ensure that non treasury accounts cannot transfer
    function testTransferNegativeNonTreasury() public ifForteTestsEnabled {
        vm.skip(SKIP_FORTE_TOKEN_TESTS);
        vm.startPrank(TREASURY_1);
        ProtocolToken(tokenAddress).transfer(USER_1, 1);
        vm.startPrank(USER_1);
        // bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        console2.log("block.timestamp",block.timestamp);
        PauseRule[] memory pauseRules = appManager.getPauseRules();
        for (uint256 i; i < pauseRules.length; ++i) {
             console2.log("pause start",pauseRules[i].pauseStart);
        }
        vm.expectRevert();
        ProtocolToken(tokenAddress).transfer(USER_2, 1);
    }

    // Ensure that the token can be upgraded
    function testUpgrade() public ifForteTestsEnabled {
        vm.skip(SKIP_FORTE_TOKEN_TESTS);
        vm.stopPrank();
        vm.startPrank(PROXY_OWNER); 
        protocolTokenUpgraded = new ProtocolToken(); 
        ProtocolTokenProxy(tokenAddress).upgradeTo(address(protocolTokenUpgraded));
        vm.stopPrank();
        vm.startPrank(USER_1); 
        assertEq(MINT_AMOUNT, ProtocolToken(tokenAddress).balanceOf(MINT_ADMIN));
    }

    // Ensure that a rule may be added and functions
    function testRule() public ifForteTestsEnabled {
        vm.skip(SKIP_FORTE_TOKEN_TESTS);
        vm.startPrank(TREASURY_1);
        ProtocolToken(tokenAddress).transfer(USER_1, 1000);
        vm.startPrank(APP_ADMIN);
        appManager.addTag(USER_1, "testTag");
        appManager.addTag(USER_2, "testTag");
        vm.startPrank(RULE_ADMIN);
        // delete the pause rule
        PauseRule[] memory pauseRules = appManager.getPauseRules();
        for (uint256 i; i < pauseRules.length; ++i) {
            appManager.removePauseRule(pauseRules[i].pauseStart,pauseRules[i].pauseStop);
        }
        uint32 ruleId = _addMinMaxTokenBalance(); 
        console2.log(ruleId);
        console2.log(address(ruleProcessorDiamond));
        console2.log(address(ERC20HandlerMainFacet(address(handlerDiamond)).getRuleProcessorAddress()));
        console2.log(address(handlerDiamond));
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC20TaggedRuleFacet(address(handlerDiamond)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        // should pass
        vm.startPrank(USER_1); 
        ProtocolToken(address(tokenAddress)).transfer(USER_2, 990); 
        assertEq(ProtocolToken(address(tokenAddress)).balanceOf(USER_2), 990);
        // should fail
        vm.expectRevert("UnderMinBalance()");
        ProtocolToken(address(tokenAddress)).transfer(USER_2, 1); 

    }

    function _addMinMaxTokenBalance() internal returns(uint32 ruleId) {
        vm.skip(SKIP_FORTE_TOKEN_TESTS);
        uint16[] memory periods;
        ruleId = TaggedRuleDataFacet(address(ruleProcessorDiamond)).addAccountMinMaxTokenBalance(address(appManager), createBytes32Array("testTag"), createUint256Array(10), createUint256Array(2000), periods, uint64(block.timestamp));
        console2.log("rule",ruleId);
        return ruleId;
    }

   /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 1
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](1);
        array[0] = arg1;
    }

   /**
    * @dev This function creates a bytes32 array to be used in tests 
    * @notice This function creates a bytes32 array size of 1 
    * @return array bytes32[] 
    */
    function createBytes32Array(bytes32 arg1) public pure returns (bytes32[] memory array) {
        array = new bytes32[](1);
        array[0] = arg1;
    }

     /**
    * @dev This function creates a uint256 array to be used in tests 
    * @notice This function creates a uint256 array size of 1 
    * @return array uint256[] 
    */
    function createUint256Array(uint256 arg1) public pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = arg1;
    }

    modifier ifForteTestsEnabled() {
        if(!SKIP_FORTE_TOKEN_TESTS){
            _;
        }
    }
}
