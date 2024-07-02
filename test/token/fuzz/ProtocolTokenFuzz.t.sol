// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol"; 

/**
 * ERC20 Upgradeable tests 
 */

contract ProtocolTokenFuzzTest is TestCommon {
    function setUp() public endWithStopPrank {
        setUpTokenWithHandler();
    }

    // test total supply changes with mint/burns 
    function testERC20Upgradeable_Fuzz_TotalSupplyChanges(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin(); 
        uint256 supplyBeforeMint = ProtocolToken(address(protocolTokenProxy)).totalSupply(); 
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, amount);
        assertEq(supplyBeforeMint + amount, ProtocolToken(address(protocolTokenProxy)).totalSupply());
    }

    function testERC20Upgradeable_Fuzz_TotalSupplyChangesMintAndBurn(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 11, type(uint256).max);
        switchToMinterAdmin(); 
        ProtocolToken(address(protocolTokenProxy)).mint(minterAdmin, amount);
        uint256 supply = ProtocolToken(address(protocolTokenProxy)).totalSupply();
        uint256 burnAmount; 
        if (amount < 100) {
            burnAmount = amount / 2;
        } else {
            burnAmount = amount - 10; 
        }
        ProtocolToken(address(protocolTokenProxy)).burn(burnAmount);
        uint256 supplyAfterBurn = ProtocolToken(address(protocolTokenProxy)).totalSupply();
        assertGt(supply, supplyAfterBurn); 
    }

    // test transfers to zero address 
    function testERC20Upgradeable_Fuzz_TransfersToZeroAddress_Negative(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer to the zero address");
        ProtocolToken(address(protocolTokenProxy)).transfer(address(0x0), amount);
    }
    // transfer more than balance reverts admin 
    function testERC20Upgradeable_Fuzz_Transfers_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(appAdministrator, amount);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), amount);
    }

    function testERC20Upgradeable_Fuzz_Transfers_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).transfer(appAdministrator, amount + 1);
    }
    // transfer more than balance reverts user 
    function testERC20Upgradeable_Fuzz_TransfersToUser_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, amount);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), amount);
    }

    function testERC20Upgradeable_Fuzz_TransfersToUser_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser(); 
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).transfer(user2, amount + 1);
    }
    // burn more than balance reverts admin 
    function testERC20Upgradeable_Fuzz_BurnAdmin_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(minterAdmin, amount);
        ProtocolToken(address(protocolTokenProxy)).burn(amount);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(minterAdmin), 0);
    }

    function testERC20Upgradeable_Fuzz_BurnAdmin_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(appAdministrator, amount);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).burn(amount + 1);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(appAdministrator), amount);
    }
    // burn more than balance reverts user 
    function testERC20Upgradeable_Fuzz_BurnUser_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).burn(amount);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 0);
    }

    function testERC20Upgradeable_Fuzz_BurnUser_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, (type(uint256).max -1));
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        vm.expectRevert("ERC20: burn amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).burn(amount + 1);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), amount);
    }
    // test allowance given to admin 
    function testERC20Upgradeable_Fuzz_Allowance_Positive(uint256 amount) public endWithStopPrank {
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        ProtocolToken(address(protocolTokenProxy)).increaseAllowance(minterAdmin, amount);
        switchToMinterAdmin(); 
        ProtocolToken(address(protocolTokenProxy)).transferFrom(user1, user2, amount);

        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), 0);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user2), amount);
    }
    // test allowance given to admin - negative
    function testERC20Upgradeable_Fuzz_Allowance_Negative(uint256 amount) public endWithStopPrank {
        amount = bound(amount, 1, type(uint256).max);
        switchToMinterAdmin();  
        ProtocolToken(address(protocolTokenProxy)).mint(user1, amount);
        switchToUser();
        // ProtocolToken(address(protocolTokenProxy)).increaseAllowance(minterAdmin, amount);
        switchToMinterAdmin(); 

        vm.expectRevert("ERC20: insufficient allowance");
        ProtocolToken(address(protocolTokenProxy)).transferFrom(user1, user2, amount);

        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(user1), amount);
    }
    // test mint is admin protected 
    function testERC20Upgradeable_Fuzz_MintAdminOnly(uint8 addrIndex1) public endWithStopPrank { 
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(addrIndex1);
        vm.startPrank(_user1);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user1), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolToken(address(protocolTokenProxy)).mint(_user1, 10000);

        vm.startPrank(_user2);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user2), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolToken(address(protocolTokenProxy)).mint(_user2, 10000);

        vm.startPrank(_user3);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user3), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolToken(address(protocolTokenProxy)).mint(_user3, 10000);

        vm.startPrank(_user4);
        vm.expectRevert(abi.encodePacked("AccessControl: account ", StringsUpgradeable.toHexString(_user4), " is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"));
        ProtocolToken(address(protocolTokenProxy)).mint(_user4, 10000);

        assertEq(ProtocolToken(address(protocolTokenProxy)).totalSupply(), 0);
    }

}