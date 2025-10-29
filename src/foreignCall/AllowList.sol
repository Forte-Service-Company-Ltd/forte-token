// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/* ───────────────────────────── Interface ───────────────────────────── */

interface IAllowList {
    function isAllowed(address account) external view returns (bool);
}

/* ───────────────────────────── AllowList ───────────────────────────── */

/** 
 * @title AllowList
 * @author @ShaneDuncan602 
 * @notice Owner-managed allowlist for gating 
 **/ 
 contract AllowList is IAllowList, Ownable {
    /* ------------------------------- Storage ------------------------------- */
    mapping(address => bool) private _allowed;

    /* -------------------------------- Events ------------------------------- */
    event Allowed(address indexed account);
    event Disallowed(address indexed account);

    /* -------------------------------- Errors ------------------------------- */
    error AlreadyAllowed(address account);
    error NotAllowedYet(address account);

    constructor(address initialOwner) {
        transferOwnership(initialOwner);
    }

    /* ------------------------------- Views --------------------------------- */
    function isAllowed(address account) external view override returns (bool) {
        // If enforcement is off, treat as allowed.
        return _allowed[account];
    }

    /* ------------------------------ Mutators ------------------------------- */

    function allow(address account) public onlyOwner {
        if (_allowed[account]) revert AlreadyAllowed(account);
        _allowed[account] = true;
        emit Allowed(account);
    }

    function disallow(address account) public onlyOwner {
        if (!_allowed[account]) revert NotAllowedYet(account);
        _allowed[account] = false;
        emit Disallowed(account);
    }

    function allowBatch(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            address a = accounts[i];
            if (!_allowed[a]) {
                _allowed[a] = true;
                emit Allowed(a);
            }
        }
    }

    function disallowBatch(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            address a = accounts[i];
            if (_allowed[a]) {
                _allowed[a] = false;
                emit Disallowed(a);
            }
        }
    }
}