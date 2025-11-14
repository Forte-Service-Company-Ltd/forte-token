// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 
import {AllowList} from "src/foreignCall/AllowList.sol";


/**
 * Shared testing logic, set ups, helper functions and global test variables for Rules Engine Testing Framework
 * Code used across multiple testing directories belongs here
 */
contract ForteRulesEngineV2TestDeploy is TestCommon {
    
    uint256 policyId;
    address policyAdminDeployed;
    address fcAdminDeployed;
    string callingFunction = "transfer(address,uint256)";
    bytes32 public constant EVENTTEXT = bytes32("Rules Engine Event");
    AllowList allowListFC;
    bool skipTest;

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
        skipTest = vm.envBool("SKIP_FORTE_TOKEN_TESTS");
        if (!skipTest){
            policyId = vm.envUint("POLICY_ID");
            policyAdminDeployed = vm.envAddress("DEPLOYMENT_OWNER");
            fcAdminDeployed = vm.envAddress("ALLOWLIST_OWNER");
            callingContractAdmin = TOKEN_ADMIN;
            red = ForteRulesEngine(payable(vm.envAddress("FORTE_RULES_ENGINE_ADDRESS")));
            // deployed proxy 
            protocolTokenProxy = ProtocolTokenProxy(payable(vm.envAddress("TOKEN_ADDRESS")));  
            _setupAddressList();
            // mint tokens
            vm.startPrank(policyAdminDeployed);
            ProtocolTokenv2(address(protocolTokenProxy)).mint(TREASURY_ADDR_1, 1_000_000);
            allowListFC = AllowList(vm.envAddress("ALLOWLIST_ADDRESS"));
        }
    }

    function _setupAddressList() internal {
        bytes[] memory addresses = new bytes[](9);
        bytes[] memory types = new bytes[](9);
        addresses[0] = abi.encode(TREASURY_ADDR_1);
        types[0] = abi.encode("T");
        addresses[1] = abi.encode(TREASURY_ADDR_2);
        types[1] = abi.encode("T");
        addresses[2] = abi.encode(STAKING_ADDR);
        types[2] = abi.encode("STK");
        addresses[3] = abi.encode(EXCHANGE_ADDR_1);
        types[3] = abi.encode("E");
        addresses[4] = abi.encode(EXCHANGE_ADDR_2);
        types[4] = abi.encode("E");
        addresses[5] = abi.encode(MULTISIG_ADDR_1);
        types[5] = abi.encode("M");
        addresses[6] = abi.encode(MULTISIG_ADDR_2);
        types[6] = abi.encode("M");
        addresses[7] = abi.encode(SELF_CUSTODY_ADDR_1);
        types[7] = abi.encode("S");
        addresses[8] = abi.encode(SELF_CUSTODY_ADDR_2);
        types[8] = abi.encode("S");

        vm.startPrank(policyAdminDeployed);
        Trackers memory returnedTracker = RulesEngineComponentFacet(address(red)).getTracker(vm.envUint("POLICY_ID"), 1);
        RulesEngineComponentFacet(address(red)).updateTracker(vm.envUint("POLICY_ID"), 1, returnedTracker, addresses, types);
    }

    /// TRANSFER    
    function testV2TransferPositiveTtoT() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(TREASURY_ADDR_2), 1);
    }

    function testV2TransferPositiveTtoM() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferPositiveTtoE() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }
    /// Staking can send/receive any S,E,or M address that is kyc'd
     function testV2TransferPositiveStaking() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(STAKING_ADDR))
            );
        assertEq(value, abi.encode("STK"));
        // Add SELF_CUSTODY_ADDR_1 to the kyc list.
        allowListFC.allow(SELF_CUSTODY_ADDR_1);
        vm.startPrank(TREASURY_ADDR_1);
        assertTrue(allowListFC.isAllowed(SELF_CUSTODY_ADDR_1));
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        // SELF_CUSTODY_ADDR_1 --> Staking 
        vm.startPrank(SELF_CUSTODY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
        // Staking --> SELF_CUSTODY_ADDR_1
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);

    }

    /// Staking can only send/receive any S,E,or M address that is kyc'd
     function testV2TransferNegativeStakingOnlyKYC() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(STAKING_ADDR))
            );
        assertEq(value, abi.encode("STK"));
        value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(TREASURY_ADDR_1))
            );
        assertEq(value, abi.encode("T"));
        // Add user 1 to the kyc list.
        allowListFC.allow(USER_1);
        // allowListFC.allow(STAKING_ADDR);
        vm.startPrank(TREASURY_ADDR_1);
        assertTrue(allowListFC.isAllowed(USER_1));
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        // USER_1 --> Staking 
        vm.startPrank(USER_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        // Staking --> User_1
        vm.startPrank(STAKING_ADDR);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 1);

    }

    /// Exchange to exchange
     function testV2TransferPositiveEtoE() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(EXCHANGE_ADDR_1))
            );
        assertEq(value, abi.encode("E"));
        value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(EXCHANGE_ADDR_2))
            );
        assertEq(value, abi.encode("E"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        // EXCHANGE_ADDR_1 --> EXCHANGE_ADDR_2 
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_2, 1);

    }

    /// Exchange to multisig
     function testV2TransferPositiveEtoM() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(EXCHANGE_ADDR_1))
            );
        assertEq(value, abi.encode("E"));
        value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(MULTISIG_ADDR_1))
            );
        assertEq(value, abi.encode("M"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        // EXCHANGE_ADDR_1 --> MULTISIG_ADDR_1 
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);

    }

    /// multisig to exchange
     function testV2TransferPositiveMtoE() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(EXCHANGE_ADDR_1))
            );
        assertEq(value, abi.encode("E"));
        value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(MULTISIG_ADDR_1))
            );
        assertEq(value, abi.encode("M"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        // MULTISIG_ADDR_1 --> EXCHANGE_ADDR_1 
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);

    }

    // Multi sig can send to S and E
    function testV2TransferPositiveMultiSig() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(MULTISIG_ADDR_1))
            );
        assertEq(value, abi.encode("M"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 10);
        
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    /// Exchanges can send to other exchanges, multisigs, and Self custody
    function testV2TransferPositiveExchange() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(EXCHANGE_ADDR_1))
            );
        assertEq(value, abi.encode("E"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 10);
        
        // Exchange to Self Custody
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    /// Self-Custody can only send to Staking and only if they are KYC'd
    function testV2TransferPositiveSelfCustody() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(SELF_CUSTODY_ADDR_1))
            );
        assertEq(value, abi.encode("S"));
       
        // Add self custody 1 to the kyc list.
        allowListFC.allow(SELF_CUSTODY_ADDR_1);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 10);
        
        // Self Custody to Staking
        vm.startPrank(SELF_CUSTODY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
    }

    function testV2TransferPositiveGas() public skipTestIfEnabled {
       
        vm.startPrank(TREASURY_ADDR_1);
        uint256 checkpointGasLeft = gasleft();
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(TREASURY_ADDR_2, 10);
        uint256 checkpointGasLeft2 = gasleft();
        // Subtract 100 to account for the warm SLOAD in startMeasuringGas.
        uint256 gasDelta = checkpointGasLeft - checkpointGasLeft2 - 100;
        console2.log("GAS USED", gasDelta);
    }

    function testV2TransferNegative_MtoNotAllowed() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(MULTISIG_ADDR_1))
            );
        assertEq(value, abi.encode("M"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 10);
        
        // Self Custody to Exhchange
        vm.startPrank(MULTISIG_ADDR_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(address(0xFF1), 1);
    }

    function testV2TransferNegative_EtoNotAllowed() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(TREASURY_ADDR_1))
            );
        assertEq(value, abi.encode("T"));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        
        vm.startPrank(EXCHANGE_ADDR_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testV2TransferNegative_StakingToNotAllowed() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        
        vm.startPrank(STAKING_ADDR);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testV2TransferNegative_NotAllowedToNotAllowed() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1);
        
        vm.startPrank(user1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2), 0);
    }

    function testV2TransferNegative_MultiToNotAllowed() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        
        vm.startPrank(MULTISIG_ADDR_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2), 0);
    }

    function testV2TransferNegative_KYCOnlyToStaking() public skipTestIfEnabled {
        vm.stopPrank();
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 10);
        vm.startPrank(fcAdminDeployed);               
        // Add self custody 1 to the kyc list.
        allowListFC.allow(USER_1);
        
        // user to Staking
        vm.startPrank(USER_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
    }

    function testV2TransferNegative_KYCOnlyToMulti() public skipTestIfEnabled {
        vm.stopPrank();
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 10);
        vm.startPrank(fcAdminDeployed);               
        // Add self custody 1 to the kyc list.
        allowListFC.allow(USER_1);
        
        // user to multi
        vm.startPrank(USER_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
    }

    function testV2TransferNegative_MultiToKYCOnly() public skipTestIfEnabled {
        vm.stopPrank();
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 10);
        vm.startPrank(fcAdminDeployed);               
        // Add self custody 1 to the kyc list.
        allowListFC.allow(USER_1);
        
        // MULTISIG_ADDR_1 to kyc'd only
        vm.startPrank(MULTISIG_ADDR_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 1);
    }

    function testV2TransferNegative_ExchangeToKYCOnly() public skipTestIfEnabled {
        vm.stopPrank();
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 10);
        vm.startPrank(fcAdminDeployed);               
        // Add self custody 1 to the kyc list.
        allowListFC.allow(USER_1);
        
        // EXCHANGE_ADDR_1 to kyc'd only
        vm.startPrank(EXCHANGE_ADDR_1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(USER_1, 1);
    }

    /// PAUSE
    function testV2PauseNegative() public skipTestIfEnabled {
        vm.startPrank(policyAdminDeployed);
        ProtocolTokenv2(address(protocolTokenProxy)).pause();
        vm.startPrank(policyAdminDeployed);
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        ProtocolTokenv2(address(protocolTokenProxy)).mint(USER_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(USER_1), 0);
    }

    /// TRANSFER FROM
    function testV2TransferFromPositive_TtoT() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,TREASURY_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(TREASURY_ADDR_2), 1);
    }

    function testV2TransferFromPositive_TtoM() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }

    function testV2TransferFromPositive_TtoE() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(TREASURY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(TREASURY_ADDR_1,EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferFromPositive_MtoS() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(MULTISIG_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(MULTISIG_ADDR_1,SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferFromPositive_MtoE() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(MULTISIG_ADDR_1, 1);
        
        vm.startPrank(MULTISIG_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(MULTISIG_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(MULTISIG_ADDR_1,EXCHANGE_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_1), 1);
    }

    function testV2TransferFromPositive_EtoE() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(EXCHANGE_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(EXCHANGE_ADDR_1,EXCHANGE_ADDR_2, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(EXCHANGE_ADDR_2), 1);
    }

    function testV2TransferFromPositive_EtoM() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(EXCHANGE_ADDR_1, 1);
        
        vm.startPrank(EXCHANGE_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(EXCHANGE_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(EXCHANGE_ADDR_1,MULTISIG_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(MULTISIG_ADDR_1), 1);
    }


    function testV2TransferFromPositive_StoStaking() public skipTestIfEnabled {
        vm.startPrank(fcAdminDeployed);
        bytes memory value = RulesEngineComponentFacet(address(red)).getMappedTrackerValue(
                policyId,
                1,
                abi.encode(address(STAKING_ADDR))
            );
        assertEq(value, abi.encode("STK"));
        // Add self custody 1 to the kyc list.
        vm.startPrank(fcAdminDeployed);
        allowListFC.allow(SELF_CUSTODY_ADDR_1);
        assertTrue(allowListFC.isAllowed(SELF_CUSTODY_ADDR_1));
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(SELF_CUSTODY_ADDR_1, 1);
        
        vm.startPrank(SELF_CUSTODY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(SELF_CUSTODY_ADDR_1, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(SELF_CUSTODY_ADDR_1,STAKING_ADDR, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(STAKING_ADDR), 1);
    }

    function testV2TransferFromPositive_StakingToS() public skipTestIfEnabled {
        // Add self custody 1 to the kyc list.
        vm.startPrank(fcAdminDeployed);
        allowListFC.allow(SELF_CUSTODY_ADDR_1);
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(STAKING_ADDR, 1);
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(STAKING_ADDR,SELF_CUSTODY_ADDR_1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(SELF_CUSTODY_ADDR_1), 1);
    }

    function testV2TransferFromNegative_StakingToNotAllowed() public skipTestIfEnabled {
        vm.startPrank(TREASURY_ADDR_1);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(STAKING_ADDR, 1);
        
        vm.startPrank(STAKING_ADDR);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(STAKING_ADDR, 1);
        vm.expectRevert("Transfer Not Authorized");
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(STAKING_ADDR,user1, 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    modifier skipTestIfEnabled() {
        if (skipTest) {
            vm.skip(true);
        }
        _;
    }
}
