// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Test.sol";
import "test/token/TestCommon.sol"; 
import "test/token/TestArrays.sol";
import {DummyAMM} from "test/token/TestTokenCommon.sol";


abstract contract ERC20UCommonTests is Test, TestCommon, TestArrays, DummyAMM {

/// all test function should use ifDeploymentTestsEnabled endWithStopPrank() modifiers
    function testERC20Upgradeable_OwnershipOfProxy_Positive() public ifDeploymentTestsEnabled endWithStopPrank { 
        assertEq(tokenAdmin, ProtocolTokenv2(address(protocolTokenProxy)).owner());
    }

    function testERC20Upgradeable_TokenRoleGranting_Positive() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToTokenAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, user1);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
    }

    function testERC20Upgradeable_TokenRoleGranting_Negative() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToUser2(); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user2), " is missing role 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6"));
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, user1);
        assertFalse(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
    }

    function testERC20Upgradeable_TokenRoleRevoking_Positive() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToTokenAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, user1);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
        ProtocolTokenv2(address(protocolTokenProxy)).revokeRole(MINTER_ROLE, user1);
        assertFalse(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));

        ProtocolTokenv2(address(protocolTokenProxy)).revokeRole(MINTER_ROLE, user1);
        assertFalse(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
    }

    function testERC20Upgradeable_TokenAdminRole_Positive() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToTokenAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(TOKEN_ADMIN_ROLE, user1);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(TOKEN_ADMIN_ROLE, user1));
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(TOKEN_ADMIN_ROLE, user2);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(TOKEN_ADMIN_ROLE, user2));
        vm.stopPrank(); 
        vm.startPrank(proxyAdmin);
        address proxyAdminCheck = ProtocolTokenProxy(payable(address(protocolTokenProxy))).admin();
        assertEq(proxyAdminCheck, proxyAdmin);
    }

    function testERC20Upgradeable_TokenRoleRevoking_Negative() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToTokenAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, user1);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
        switchToUser();
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user1), " is missing role 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6"));
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, user1);
        assertTrue(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(MINTER_ROLE, user1));
    }

    function testERC20Upgradeable_TokenConnectHandler_Positive() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToTokenAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).connectHandlerToToken(address(0x777)); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).getHandlerAddress(), address(0x777)); 
    }

    function testERC20Upgradeable_TokenConnectHandler_Negative() public ifDeploymentTestsEnabled endWithStopPrank { 
        switchToMinterAdmin(); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(minterAdmin), " is missing role 0x9e262e26e9d5bf97da5c389e15529a31bb2b13d89967a4f6eab01792567d5fd6"));
        ProtocolTokenv2(address(protocolTokenProxy)).connectHandlerToToken(address(0x777)); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).getHandlerAddress(), address(red)); 
    }

    function testERC20Upgradeable_MintToProxyAdmin_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(proxyAdmin); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(proxyAdmin, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(proxyAdmin));
    }

    function testERC20Upgradeable_MintToAppAdmin_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin));
    }

    function testERC20Upgradeable_MintToUser_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_Mint_NotAdmin_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToUser();
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        assertEq(balanceBeforeMint, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_Mint_NotAppAdmin_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToUser();
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        assertEq(balanceBeforeMint, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_TransferFromAppAdminToUser_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 balanceBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin));
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1000);
        assertEq(1000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_TransferFromUserToUser_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user2, 1000);
        assertEq(1000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2));
    }

    function testERC20Upgradeable_TransferFromUserToUser_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user2, 10000);
        switchToUser();
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 1000);
        assertEq(10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2));
    }

    function testERC20Upgradeable_AdminBurn_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 10000);
        ProtocolTokenv2(address(protocolTokenProxy)).burn(1000);
        assertEq(9000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin));
    }

    function testERC20Upgradeable_UserBurn_Postive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        ProtocolTokenv2(address(protocolTokenProxy)).burn(1000);
        assertEq(9000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_UserBurn_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).burn(11000);
        assertEq(10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_AdminBurn_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 10000);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).burn(11000);
        assertEq(10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin));
    }

    function testERC20Upgradeable_Upgrade() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 10000);
        vm.stopPrank();
        vm.startPrank(proxyAdmin); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));
        switchToMinterAdmin();
        assertEq(10000, ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin));
        // ensure that only admins can mint with new logic contract
        switchToUser(); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 10000);
    }

    function testERC20Upgradeable_Upgrade_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        vm.stopPrank();
        vm.startPrank(user1); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        vm.expectRevert("Not Authorized.");
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));
    }

    function testERC20Upgradeable_UpgradedRuleDataRetention_Positive() public ifDeploymentTestsEnabled endWithStopPrank {
        // use max trading volume buy action for rule test data 
        // rule uses accumulation data stored for the token 
        tokenAmm = setUpAMM();
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(testTokenProxy)).mint(minterAdmin, 1001);
        _mintToAdminAndUsers();
        switchToUser();
        switchToMinterAdmin(); 
        tokenAmm.dummyTrade(address(protocolTokenProxy), address(testTokenProxy), 50, 50, false);
        assertEq(ProtocolTokenv2(address(testTokenProxy)).balanceOf(minterAdmin), 951);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1050);
        // upgrade the logic contract 
        vm.stopPrank();
        vm.startPrank(proxyAdmin); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));
        switchToTokenAdmin();
        ProtocolTokenv2(address(protocolTokenProxy)).connectHandlerToToken(address(red));
        assertEq(ProtocolTokenv2(address(testTokenProxy)).balanceOf(minterAdmin), 951);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1050);

    }


    function testERC20U_ForkTesting_IsProxyAdmin() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToProxyAdmin();
        assertEq(protocolTokenProxy.admin(), proxyAdmin);
    }

    function testERC20U_ForkTesting_IsAppAdministrator_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(TOKEN_ADMIN_ROLE, user1), false);
    }

    function testERC20U_ForkTesting_IsTokenAdministrator_Positive() public ifDeploymentTestsEnabled endWithStopPrank {
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).hasRole(TOKEN_ADMIN_ROLE, tokenAdmin), true);
    }

    function testERC20U_ForkTesting_TestMinting_Positive() public ifDeploymentTestsEnabled endWithStopPrank {        
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin), 1000);
    }

    function testERC20U_ForkTesting_TestMinting_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToUser(); 
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin), 0);
    }

    function testERC20U_ForkTesting_TestBurn_Positive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1000);
        ProtocolTokenv2(address(protocolTokenProxy)).burn(900);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 100);
    }

    function testERC20U_ForkTesting_TestBurn_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1000);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).burn(9000);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1000);
    }

    function testERC20U_ForkTesting_TestTransfers_Positive() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1000);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 500);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 500);
    }

    function testERC20U_ForkTesting_TestTransfers_Negative() public ifDeploymentTestsEnabled endWithStopPrank {
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin), 1000);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user1, 5000);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }


    // TEST HELPER FUNCTIONS 
    function setUpAMM() internal returns (DummyAMM){
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 1_000_000_000); 
        tokenAmm = new DummyAMM(); 
        ProtocolTokenv2(address(protocolTokenProxy)).approve(address(tokenAmm), 1000000); 
        switchToTokenAdmin();
        // create second token for AMM swaps 
        testToken = _deployERC20UpgradeableNonDeterministic(); 
        // deploy proxy 
        testTokenProxy = _deployERC20UpgradeableProxyNonDeterministic(address(testToken), proxyAdmin); 
         
        ProtocolTokenv2(address(testTokenProxy)).initialize("Test", "TEST", tokenAdmin); 
        ProtocolTokenv2(address(testTokenProxy)).grantRole(MINTER_ROLE, minterAdmin);
        ProtocolTokenv2(address(testTokenProxy)).connectHandlerToToken(address(red)); 
        switchToMinterAdmin();
        ProtocolTokenv2(address(testTokenProxy)).mint(minterAdmin, 1_000_000_000);
        ProtocolTokenv2(address(testTokenProxy)).approve(address(tokenAmm), 1000000);
        /// fund the amm with 
        ProtocolTokenv2(address(testTokenProxy)).transfer(address(tokenAmm), 1_000_000_000);
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(address(tokenAmm), 1_000_000_000);
        /// User 1 gives approvals 
        switchToUser(); 
        ProtocolTokenv2(address(testTokenProxy)).approve(address(tokenAmm), 1000000);
        ProtocolTokenv2(address(protocolTokenProxy)).approve(address(tokenAmm), 1000000);

        return tokenAmm;
    }

    function _mintToAdminAndUsers() internal {
        switchToMinterAdmin(); 
        //admin mint 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 1000); 
        // user 1 mint 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 1000);
        // user 2 mint 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user2, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2), 1000);
        // user 3 mint 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user3, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user3), 1000);
        // user 4 mint 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user4, 1000); 
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user4), 1000);
    }
}
