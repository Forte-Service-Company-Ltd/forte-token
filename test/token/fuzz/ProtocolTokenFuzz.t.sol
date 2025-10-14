// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 

/**
 * ERC20 Upgradeable tests 
 */

contract ProtocolTokenv2FuzzTest is TestCommon {
    function setUp() public endWithStopPrank {
        setUpTokenWithEngine();
    }

    // test total supply changes with mint/burns 
    function testERC20Upgradeable_Fuzz_TotalSupplyChanges(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 supplyBeforeMint = ProtocolTokenv2(address(protocolTokenProxy)).totalSupply(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, amount);
        assertEq(supplyBeforeMint + amount, ProtocolTokenv2(address(protocolTokenProxy)).totalSupply());
    }

    function testERC20Upgradeable_Fuzz_TotalSupplyChangesMintAndBurn(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 11, type(uint256).max);
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, amount);
        uint256 supply = ProtocolTokenv2(address(protocolTokenProxy)).totalSupply();
        uint256 burnAmount; 
        if (amount < 100) {
            burnAmount = amount / 2;
        } else {
            burnAmount = amount - 10; 
        }
        ProtocolTokenv2(address(protocolTokenProxy)).burn(burnAmount);
        uint256 supplyAfterBurn = ProtocolTokenv2(address(protocolTokenProxy)).totalSupply();
        assertGt(supply, supplyAfterBurn); 
    }

    // test transfers to zero address 
    function testERC20Upgradeable_Fuzz_TransfersToZeroAddress_Negative(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer to the zero address");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(address(0x0), amount);
    }
    // transfer more than balance reverts admin 
    function testERC20Upgradeable_Fuzz_Transfers_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(tokenAdmin, amount);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin), amount);
    }

    function testERC20Upgradeable_Fuzz_Transfers_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(tokenAdmin, amount + 1);
    }
    // transfer more than balance reverts user 
    function testERC20Upgradeable_Fuzz_TransfersToUser_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user2, amount);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2), amount);
    }

    function testERC20Upgradeable_Fuzz_TransfersToUser_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).transfer(user2, amount + 1);
    }
    // burn more than balance reverts admin 
    function testERC20Upgradeable_Fuzz_BurnAdmin_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(minterAdmin, amount);
        ProtocolTokenv2(address(protocolTokenProxy)).burn(amount);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(minterAdmin), 0);
    }

    function testERC20Upgradeable_Fuzz_BurnAdmin_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(tokenAdmin, amount);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).burn(amount + 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(tokenAdmin), amount);
    }
    // burn more than balance reverts user 
    function testERC20Upgradeable_Fuzz_BurnUser_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        ProtocolTokenv2(address(protocolTokenProxy)).burn(amount);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testERC20Upgradeable_Fuzz_BurnUser_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolTokenv2(address(protocolTokenProxy)).burn(amount + 1);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), amount);
    }
    // test allowance given to admin 
    function testERC20Upgradeable_Fuzz_Allowance_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        ProtocolTokenv2(address(protocolTokenProxy)).increaseAllowance(minterAdmin, amount);
        switchToMinterAdmin(); 
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(user1, user2, amount);

        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), 0);
        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user2), amount);
    }
    // test allowance given to admin - negative
    function testERC20Upgradeable_Fuzz_Allowance_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, type(uint256).max);
        switchToMinterAdmin();  
        ProtocolTokenv2(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        switchToMinterAdmin(); 

        vm.expectRevert("ERC20: insufficient allowance");
        ProtocolTokenv2(address(protocolTokenProxy)).transferFrom(user1, user2, amount);

        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).balanceOf(user1), amount);
    }
    // test mint is admin protected 
    function testERC20Upgradeable_Fuzz_MintAdminOnly(uint8 addrIndex1) public endWithStopPrank { 
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(addrIndex1);
        vm.startPrank(_user1);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(_user1, 10000);

        vm.startPrank(_user2);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user2), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(_user2, 10000);

        vm.startPrank(_user3);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user3), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(_user3, 10000);

        vm.startPrank(_user4);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user4), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolTokenv2(address(protocolTokenProxy)).mint(_user4, 10000);

        assertEq(ProtocolTokenv2(address(protocolTokenProxy)).totalSupply(), 0);
    }

    function testERC20Upgradeable_Upgrade_AdminOnly(uint8 addrIndex1) public ifDeploymentTestsEnabled endWithStopPrank {
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(addrIndex1);
        
        vm.stopPrank();
        vm.startPrank(_user1); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        vm.expectRevert("Not Authorized.");
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));

        vm.stopPrank();
        vm.startPrank(_user2); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        vm.expectRevert("Not Authorized.");
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));

        vm.stopPrank();
        vm.startPrank(_user3); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        vm.expectRevert("Not Authorized.");
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));

        vm.stopPrank();
        vm.startPrank(_user4); 
        protocolTokenUpgraded = new ProtocolTokenv2(); 
        vm.expectRevert("Not Authorized.");
        protocolTokenProxy.upgradeTo(address(protocolTokenUpgraded));
    }

}