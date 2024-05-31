// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./ERC20UCommon.t.i.sol";

/**
 * @title ERC20 Mint Burn Invariant Test
 * @author @ShaneDuncan602, @TJ-Everett, @mpetersoCode55, @VoR0220, @Palmerg4
 * @dev This is the invariant test for ERC20U mint/burn functionality.
 */
contract ApplicationERC20MintBurnInvariantTest is ERC20UCommon {

    function setUp() public {
        prepERC20AndEnvironment();
    }

    // Burn should update user balance and total supply
    function invariant_ERC20external_burn() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1);
        uint256 supply = ProtocolToken(address(protocolTokenProxy)).totalSupply();
        if(!(balance_sender > 0))return;
        uint256 burn_amount = amount % (balance_sender + 1);

        vm.startPrank(USER1);
        ProtocolToken(address(protocolTokenProxy)).burn(burn_amount);
        assertEq(
            ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1),
            balance_sender - burn_amount
        );
        assertEq(
            ProtocolToken(address(protocolTokenProxy)).totalSupply(),
            supply - burn_amount
        );
    }

    // Burn should update user balance and total supply when burnFrom is called twice
    function invariant_ERC20external_burnFrom() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1);
        uint256 allowance = ProtocolToken(address(protocolTokenProxy)).allowance(USER1, USER2);
        if(!(balance_sender > 0 && allowance > balance_sender))return;
        uint256 supply = ProtocolToken(address(protocolTokenProxy)).totalSupply();
        uint256 burn_amount = amount % (balance_sender + 1);

        ProtocolToken(address(protocolTokenProxy)).burnFrom(USER1, burn_amount);
        assertEq(
            ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1),
            balance_sender - burn_amount
        );
        assertEq(
            ProtocolToken(address(protocolTokenProxy)).totalSupply(),
            supply - burn_amount
        );
    }

    // burnFrom should update allowance
    function invariant_ERC20external_burnFromUpdateAllowance() public {
        uint256 balance_sender = ProtocolToken(address(protocolTokenProxy)).balanceOf(USER1);
        uint256 current_allowance = ProtocolToken(address(protocolTokenProxy)).allowance(USER1, address(this));
        if(!(balance_sender > 0 && current_allowance > balance_sender))return;
        uint256 burn_amount = amount % (balance_sender + 1);

        ProtocolToken(address(protocolTokenProxy)).burnFrom(USER1, burn_amount);

        // Some implementations take an allowance of 2**256-1 as infinite, and therefore don't update
        if (current_allowance != type(uint256).max) {
            assertEq(
                ProtocolToken(address(protocolTokenProxy)).allowance(USER1, address(this)),
                current_allowance - burn_amount
            );
        }
    }

}