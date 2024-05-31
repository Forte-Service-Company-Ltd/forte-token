// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ERC20UCommon.t.i.sol";

/**
 * @title ERC20 Basic Invariant Test
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4
 * @dev This is the invariant test for ERC20U general functionality.
 */
contract ApplicationERC20BasicInvariantTest is ERC20UCommon {
    
    function setUp() public {
        prepERC20AndEnvironment();
    }

    // User balance must not exceed total supply
    function invariant_ERC20external_userBalanceNotHigherThanSupply() public view {
        assertLe(ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender), ProtocolToken(address(protocolTokenProxy)).totalSupply(), "User balance higher than total supply");
    }

    // Sum of users balance must not exceed total supply
    function invariant_ERC20external_userBalancesLessThanTotalSupply() public view {
        uint256 sumBalances = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this)) + ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1) + ProtocolToken(address(protocolTokenProxy)).balanceOf(USER2) + ProtocolToken(address(protocolTokenProxy)).balanceOf(USER3);
        assertLe(sumBalances, ProtocolToken(address(protocolTokenProxy)).totalSupply(), "Sum of user balances are greater than total supply");
    }

    // Address zero should have zero balance
    function invariant_ERC20external_zeroAddressBalance() public view {
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(address(0)), 0, "Address zero balance not equal to zero");
    }

    // Transfers to zero address should not be allowed
    function invariant_ERC20external_transferToZeroAddress() public {
        (, msgSender, ) = vm.readCallers();
        uint256 balance = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(msgSender));
        if (balance > 0) {
            vm.startPrank(msgSender);
            vm.expectRevert("ERC20: transfer to the zero address");
            ProtocolToken(address(protocolTokenProxy)).transfer(address(0), balance);
        }
        assertEq(balance, ProtocolToken(address(protocolTokenProxy)).balanceOf((msgSender)));
    }

    // transferFroms to zero address should not be allowed
    function invariant_ERC20external_transferFromToZeroAddress() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;
        uint256 maxValue = balance_sender >= allowance ? allowance : balance_sender;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, address(0), value % (maxValue + 1));
        assertFalse(r);
    }

    // Self transfers should not break accounting
    function invariant_ERC20external_selfTransferFrom() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;
        uint256 maxValue = balance_sender >= allowance ? allowance : balance_sender;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, msg.sender, value % (maxValue + 1));
        assertFalse(r);
        assertEq(balance_sender, ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender));
    }

    // Self transferFroms should not break accounting
    function invariant_ERC20external_selfTransfer() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this));
        if (!(balance_sender > 0)) return;

        bool r = ProtocolToken(address(protocolTokenProxy)).transfer(address(this), value % (balance_sender + 1));
        assertTrue(r);
        assertEq(balance_sender, ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this)));
    }

    // Transfers for more than available balance should not be allowed
    function invariant_ERC20external_transferFromMoreThanBalance() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > balance_sender)) return;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, target, balance_sender + 1);
        assertFalse(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender), balance_sender);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver);
    }

    // TransferFroms for more than available balance should not be allowed
    function invariant_ERC20external_transferMoreThanBalance() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this));
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        if (!(balance_sender > 0)) return;

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ProtocolToken(address(protocolTokenProxy)).transfer(target, balance_sender + 1);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this)), balance_sender);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver);
    }

    // Zero amount transfers should not break accounting
    function invariant_ERC20external_transferZeroAmount() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this));
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        if (!(balance_sender > 0)) return;

        bool r = ProtocolToken(address(protocolTokenProxy)).transfer(target, 0);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this)), balance_sender);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver);
    }

    // Zero amount transferFroms should not break accounting
    function invariant_ERC20external_transferFromZeroAmount() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && allowance > 0)) return;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, target, 0);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender), balance_sender);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver);
    }

    // Transfers should update accounting correctly
    function invariant_ERC20external_transfer() public {
        if (!(target != address(this))) return;
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this));
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        if (!(balance_sender > 2)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = ProtocolToken(address(protocolTokenProxy)).transfer(target, transfer_value);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(address(this)), balance_sender - transfer_value);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver + transfer_value);
    }

    // TransferFroms should update accounting correctly
    function invariant_ERC20external_transferFrom() public {
        if (!(target != address(this))) return;
        if (!(target != msg.sender)) return;
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 balance_receiver = ProtocolToken(address(protocolTokenProxy)).balanceOf(target);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 2 && allowance > balance_sender)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, target, transfer_value);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender), balance_sender - transfer_value);
        assertEq(ProtocolToken(address(protocolTokenProxy)).balanceOf(target), balance_receiver + transfer_value);
    }

    // Approve should set correct allowances
    function invariant_ERC20external_setAllowance() public {
        bool r = ProtocolToken(address(protocolTokenProxy)).approve(target, amount);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).allowance(address(this), target), amount);
    }

    // Allowances should be updated correctly when approve is called twice.
    function invariant_ERC20external_setAllowanceTwice() public {
        bool r = ProtocolToken(address(protocolTokenProxy)).approve(target, amount);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).allowance(address(this), target), amount);

        r = ProtocolToken(address(protocolTokenProxy)).approve(target, amount / 2);
        assertTrue(r);
        assertEq(ProtocolToken(address(protocolTokenProxy)).allowance(address(this), target), amount / 2);
    }

    // TransferFrom should decrease allowance
    function invariant_ERC20external_spendAllowanceAfterTransfer() public {
        if (!(target != address(this) && target != address(0))) return;
        if (!(target != msg.sender)) return;
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(msg.sender);
        uint256 current_allowance = ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this));
        if (!(balance_sender > 0 && current_allowance > balance_sender)) return;
        uint256 transfer_value = (amount % balance_sender) + 1;

        bool r = ProtocolToken(address(protocolTokenProxy)).transferFrom(msg.sender, target, transfer_value);
        assertTrue(r);

        // Some implementations take an allowance of 2**256-1 as infinite, and therefore don't update
        if (current_allowance != type(uint256).max) {
            assertEq(ProtocolToken(address(protocolTokenProxy)).allowance(msg.sender, address(this)), current_allowance - transfer_value);
        }
    }
}