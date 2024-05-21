// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 

/**
 * ERC20 Upgradeable tests 
 */

contract ProtocolTokenTest is TestCommon {
    function setUp() public endWithStopPrank {
        setUpTokenWithHandler();
    }

    function testERC20Upgradeable_MintToSuperAdmin_Postive() public endWithStopPrank {
        switchToAppAdministrator(); 
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(superAdmin); 
        ProtocolToken(address(protocolTokenProxy)).mint(superAdmin, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(superAdmin));
    }

    function testERC20Upgradeable_MintToAppAdmin_Postive() public endWithStopPrank {
        switchToAppAdministrator(); 
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator));
    }

    function testERC20Upgradeable_MintToUser_Postive() public endWithStopPrank {
        switchToAppAdministrator(); 
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(user1); 
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_Mint_NotAdmin_Negative() public endWithStopPrank {
        switchToUser();
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(user1); 
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
        assertEq(balanceBeforeMint, ProtocolToken(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_Mint_NotAppAdmin_Negative() public endWithStopPrank {
        switchToSuperAdmin();
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(superAdmin); 
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ProtocolToken(address(protocolTokenProxy)).mint(superAdmin, 10000);
        assertEq(balanceBeforeMint, ProtocolToken(address(protocolTokenProxy)).balanceOf(superAdmin));
    }

    function testERC20Upgradeable_TransferFromAppAdminToUser_Postive() public endWithStopPrank {
        switchToAppAdministrator(); 
        uint256 balanceBeforeMint = ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 10000);
        assertEq(balanceBeforeMint + 10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator));
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000);
        assertEq(1000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_TransferFromUserToUser_Postive() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, 1000);
        assertEq(1000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user2));
    }

    function testERC20Upgradeable_TransferFromUserToUser_Negative() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(user2, 10000);
        switchToUser();
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).transfer(user1, 1000);
        assertEq(10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user2));
    }

    function testERC20Upgradeable_AdminBurn_Postive() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 10000);
        ProtocolToken(address(protocolTokenProxy)).burn(1000);
        assertEq(9000, ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator));
    }

    function testERC20Upgradeable_UserBurn_Postive() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).burn(1000);
        assertEq(9000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_UserBurn_Negative() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
        switchToUser();
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).burn(11000);
        assertEq(10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(user1));
    }

    function testERC20Upgradeable_AdminBurn_Negative() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 10000);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).burn(11000);
        assertEq(10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator));
    }

    function testERC20Upgradeable_Upgrade() public endWithStopPrank {
        switchToAppAdministrator();  
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, 10000);
        vm.stopPrank();
        vm.startPrank(proxyOwner); 
        protocolTokenUpgraded = new ProtocolToken(); 
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));
        switchToAppAdministrator();
        assertEq(10000, ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator));
        // ensure that only admins can mint with new logic contract
        switchToUser(); 
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ProtocolToken(address(protocolTokenProxy)).mint(user1, 10000);
    }
}