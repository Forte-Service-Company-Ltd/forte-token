// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 
import "src/foreignCall/AllowList.sol";


/**
 * Shared testing logic, set ups, helper functions and global test variables for Rules Engine Testing Framework
 * Code used across multiple testing directories belongs here
 */
contract ForteRulesEngineV2Test is TestCommon {
    
    string constant POLICY_NAME = "FORTE Token Policy";
    string constant POLICY_DESCRIPTION = "Policy for the FORTE token.";
    string constant RULE_1 = "Rule 1";
    string constant RULE_1_DESCRIPTION = "Rule 1 Description";
    uint8 constant FLAG_FOREIGN_CALL = 0x01; // 00000001
    string callingFunction = "transfer(address,uint256)";
    bytes32 public constant EVENTTEXT = bytes32("Rules Engine Event");
    AllowList allowListFC;

    uint256[][] ruleIds;
    bytes4[] callingFunctions;

    // These addresses are used for policy testing and will be loaded to the allowList by number. 
    address constant TREASURY_ADDR_1 = address(1);
    address constant TREASURY_ADDR_2 = address(2);
    address constant STAKING_ADDR = address(3);
    address constant EXCHANGE_ADDR_1 = address(4);
    address constant EXCHANGE_ADDR_2 = address(5);
    address constant MULTISIG_ADDR_1 = address(6);
    address constant MULTISIG_ADDR_2 = address(7);
    address constant SELF_CUSTODY_ADDR_1 = address(8);
    address constant SELF_CUSTODY_ADDR_2 = address(9);

    function setUp() public {
        policyAdmin = MINTER_ADMIN;
        callingContractAdmin = TOKEN_ADMIN;
        vm.startPrank(RED_OWNER);
        red = createRulesEngineDiamond(RED_OWNER);
        // deploy token 
        protocolToken = _deployERC20UpgradeableV2(); 
        // deploy proxy 
        protocolTokenProxy = _deployERC20UpgradeableProxy(address(protocolToken), PROXY_OWNER); 
        // Connect proxy to token
        ProtocolTokenv2(address(protocolTokenProxy)).initialize("Token", "TOK", TOKEN_ADMIN); 
        vm.startPrank(TOKEN_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, MINTER_ADMIN);
        // Connect token to Fore Rules Engine
        vm.startPrank(TOKEN_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).connectHandlerToToken(address(red));
        ProtocolTokenv2(address(protocolTokenProxy)).setCallingContractAdmin(callingContractAdmin);
        // mint tokens
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).mint(MINTER_ADMIN, 1_000_000);
        _setupAllowList();
    }

    function _setupAllowList() internal {
        vm.startPrank(TOKEN_ADMIN);
        allowListFC = new AllowList(TOKEN_ADMIN);
        for (uint160 i = 1; i <= 9; i++) {
            allowListFC.allow(address(i));
        }
    }

    /// TRANSFER
    function testV2TransferPositiveNoPolicy() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(USER_1), 1);
    }

    function testV2TransferPositiveTtoT() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(TREASURY_ADDR_2), 1);
    }

    function testV2TransferPositiveTtoM() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferPositiveTtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferPositiveMtoS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferPositiveMtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferPositiveEtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_2), 1);
    }

    function testV2TransferPositiveEtoM() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferPositiveEtoS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferPositiveStoStaking() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(SELF_CUSTODY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
    }

    function testV2TransferPositive_StakingToS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferNegative_TtoNotAllowed() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        vm.expectRevert("Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testV2TransferNegative_MtoNotAllowed() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(MULTISIG_ADDR_1);
        vm.expectRevert("Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testV2TransferNegative_EtoNotAllowed() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        vm.expectRevert("Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testV2TransferNegative_StakingToNotAllowed() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(STAKING_ADDR);
        vm.expectRevert("Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    /// TRANSFER FROM
    function testV2TransferFromPositive_TtoT() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,TREASURY_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(TREASURY_ADDR_2), 1);
    }

    function testV2TransferFromPositive_TtoM() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferFromPositive_TtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferFromPositive_MtoS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(MULTISIG_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(MULTISIG_ADDR_1,STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
    }

    function testV2TransferFromPositive_MtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(MULTISIG_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(MULTISIG_ADDR_1,EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferFromPositive_EtoE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(EXCHANGE_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(EXCHANGE_ADDR_1,EXCHANGE_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_2), 1);
    }

    function testV2TransferFromPositive_EtoM() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(EXCHANGE_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(EXCHANGE_ADDR_1,MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferFromPositive_EtoS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(EXCHANGE_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(EXCHANGE_ADDR_1,SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferFromPositive_StoStaking() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(SELF_CUSTODY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(SELF_CUSTODY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(SELF_CUSTODY_ADDR_1,STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
    }

    function testV2TransferFromPositive_StakingToS() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(STAKING_ADDR, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(STAKING_ADDR,SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferFromNegative_StakingToNotAllowed() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(STAKING_ADDR, 1);
        vm.expectRevert("Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(STAKING_ADDR,user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }
    function testV2TransferFromPositive_StakingToE() public {
        vm.startPrank(MINTER_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        setupProductionRule(EffectTypes.REVERT);
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(STAKING_ADDR, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(STAKING_ADDR,EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function setupProductionRule(
        EffectTypes _effectType) endWithStopPrank public returns (uint256 policyId) {
        uint256[] memory policyIds = new uint256[](1);

        policyIds[0] = _createBlankPolicy();
        // Save the Policy
        callingFunctions.push(bytes4(keccak256(bytes("transfer(address,uint256)"))));
        callingFunctions.push(bytes4(keccak256(bytes("transferFrom(address,address,uint256)"))));
        
        _createCallingFunction(policyIds[0], "transfer(address,uint256)");
        _createCallingFunction(policyIds[0], "transferFrom(address,address,uint256)");
        _addCallingFunctionsToPolicy(policyIds[0]);

        // Rule: FC:exists(toAddress) == false -> revert -> transfer(address _to, uint256 amount) returns (bool)"
        Rule memory rule;
        /// Build the calling Function to include additional pTypes to match the data being passed in
        ParamTypes[] memory pTypes = new ParamTypes[](4);
        pTypes[0] = ParamTypes.ADDR;
        pTypes[1] = ParamTypes.UINT;
        pTypes[2] = ParamTypes.ADDR;
        pTypes[3] = ParamTypes.ADDR;

        ParamTypes[] memory fcArgs = new ParamTypes[](1);
        fcArgs[0] = ParamTypes.ADDR;        
        ForeignCall memory fc;
        fc.encodedIndices = new ForeignCallEncodedIndex[](1);
        fc.encodedIndices[0].index = 0;
        fc.encodedIndices[0].eType = EncodedIndexType.ENCODED_VALUES;
        fc.parameterTypes = fcArgs;
        fc.foreignCallAddress = address(allowListFC);
        fc.signature = bytes4(keccak256(bytes("isAllowed(address)")));
        fc.returnType = ParamTypes.UINT;
        fc.foreignCallIndex = 1;
        uint256 foreignCallId = RulesEngineForeignCallFacet(address(red)).createForeignCall(
            policyIds[0],
            fc,
            "isAllowed(address)",
            "isAllowed(address)"
        );

        rule.instructionSet = new uint256[](7);
        rule.instructionSet[0] = uint(LogicalOp.PLH);
        rule.instructionSet[1] = 2;
        rule.instructionSet[2] = uint(LogicalOp.NUM);
        rule.instructionSet[3] = 1;
        rule.instructionSet[4] = uint(LogicalOp.EQ);
        rule.instructionSet[5] = 0;
        rule.instructionSet[6] = 1;

        rule.rawData.argumentTypes = new ParamTypes[](1);
        rule.rawData.dataValues = new bytes[](1);
        rule.rawData.instructionSetIndex = new uint256[](1);
        rule.rawData.argumentTypes[0] = ParamTypes.ADDR;
        rule.rawData.dataValues[0] = abi.encode(0x1234567);
        rule.rawData.instructionSetIndex[0] = 3;

        rule.placeHolders = new Placeholder[](3);
        rule.placeHolders[0].pType = ParamTypes.ADDR;
        rule.placeHolders[0].typeSpecificIndex = 0; // to address
        rule.placeHolders[1].pType = ParamTypes.UINT;
        rule.placeHolders[1].typeSpecificIndex = 1; // amount
        rule.placeHolders[2].pType = ParamTypes.ADDR;
        rule.placeHolders[2].typeSpecificIndex = 2; // additional address param
        rule.placeHolders[2].flags = FLAG_FOREIGN_CALL;
        rule.placeHolders[2].typeSpecificIndex = uint128(foreignCallId);
    
        rule.negEffects = new Effect[](1);
            if (_effectType == EffectTypes.REVERT) {
                rule.negEffects[0] = _createEffectRevert("Not Authorized");
            }
        
        RulesEngineForeignCallFacet(address(red)).createForeignCall(policyIds[0], fc, "isAllowed(address)", "isAllowed(address)");
        // Save the rule
        uint256 ruleId = RulesEngineRuleFacet(address(red)).createRule(policyIds[0], rule, RULE_1, RULE_1_DESCRIPTION);

        ruleIds.push(new uint256[](1));
        ruleIds.push(new uint256[](1));
        ruleIds[0][0] = ruleId;
        ruleIds[1][0] = ruleId;
        _addRuleIdsToPolicy(policyIds[0], ruleIds);
        vm.stopPrank();
        vm.startPrank(TOKEN_ADMIN);
        RulesEnginePolicyFacet(address(red)).applyPolicy(address(protocolTokenProxy), policyIds);

        return policyIds[0];
    }

    function _addRuleIdsToPolicy(uint256 policyId, uint256[][] memory _ruleIds) internal {
        vm.stopPrank();
        vm.startPrank(policyAdmin);
        console2.log("callingFunctions", callingFunctions.length);
        console2.log("_ruleIds", _ruleIds.length);
        RulesEnginePolicyFacet(address(red)).updatePolicy(
            policyId,
            callingFunctions,
            _ruleIds,
            PolicyType.CLOSED_POLICY,
            POLICY_NAME,
            POLICY_DESCRIPTION
        );
    }

    function _createEffectRevert(string memory _text) public pure returns (Effect memory) {
        uint256[] memory emptyArray = new uint256[](0);
        // Create a revert effect
        return
            Effect({
                valid: true,
                dynamicParam: false,
                effectType: EffectTypes.REVERT,
                pType: ParamTypes.STR,
                param: abi.encode(_text),
                text: EVENTTEXT,
                errorMessage: _text,
                instructionSet: emptyArray,
                eventPlaceholderIndex: 0
            });
    }

    function _createInstructionSet(uint256 plh1) public pure returns (uint256[] memory instructionSet) {
        instructionSet = new uint256[](7);
        instructionSet[0] = uint(LogicalOp.PLH);
        instructionSet[1] = 0;
        instructionSet[2] = uint(LogicalOp.NUM);
        instructionSet[3] = plh1;
        instructionSet[4] = uint(LogicalOp.GT);
        instructionSet[5] = 0;
        instructionSet[6] = 1;
    }

    function _createCallingFunction(uint256 policyId, string memory _callingFunction) internal returns (bytes4) {
        vm.stopPrank();
        vm.startPrank(policyAdmin);
        ParamTypes[] memory pTypes = new ParamTypes[](2);
        pTypes[0] = ParamTypes.ADDR;
        pTypes[1] = ParamTypes.UINT;
        // Save the calling function
        RulesEngineComponentFacet(address(red)).createCallingFunction(
            policyId,
            bytes4(bytes4(keccak256(bytes(_callingFunction)))),
            pTypes,
            _callingFunction,
            "",
            _callingFunction
        );
        
        return bytes4(bytes4(keccak256(bytes(_callingFunction))));
    }

    function _addCallingFunctionsToPolicy(uint256 _policyId) internal {
        uint256[][] memory blankRuleIds = new uint256[][](2);
        RulesEnginePolicyFacet(address(red)).updatePolicy(
            _policyId,
            callingFunctions,
            blankRuleIds,
            PolicyType.CLOSED_POLICY,
            POLICY_NAME,
            POLICY_DESCRIPTION
        );
    }


    function _createBlankPolicy() internal returns (uint256) {
        uint256 policyId = RulesEnginePolicyFacet(address(red)).createPolicy(PolicyType.CLOSED_POLICY, POLICY_NAME, POLICY_DESCRIPTION);
        RulesEngineComponentFacet(address(red)).addClosedPolicySubscriber(policyId, callingContractAdmin);
        return policyId;
    }
    
}
