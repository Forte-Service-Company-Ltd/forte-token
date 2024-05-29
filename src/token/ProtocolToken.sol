// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "tron/client/token/IProtocolTokenHandler.sol";
import "tron/client/token/ProtocolTokenCommonU.sol";

/**
 * @title ERC20 Upgradable Protocol Token Contract
 * @author @ShaneDuncan602, @TJ-Everett, @VoR0220, @Palmerg4
 * @notice Protocol ERC20 Upgradeable for gaming liquidity 
 */

contract ProtocolToken is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable, ProtocolTokenCommonU, ReentrancyGuard  {
    address public handlerAddress;
    IProtocolTokenHandler handler;
     uint256[50] reservedStorage;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        //_disableInitializers();
    }

    /**
     * @dev Initializer sets the name, symbol and the App Manager and Handler Address
     * @notice This function should be called in an "atomic" deploy script when deploying an ERC20Upgradeable contract. 
     * "Front Running" is possible if this function is called individually after the ERC20Upgradeable proxy is deployed. 
     * It is critical to ensure your deploy process mitigates this risk.
     * @param _nameProto Name of the Token
     * @param _symbolProto Symbol for the Token
     * @param _appManagerAddress Address of App Manager
     */
   function initialize(string memory _nameProto, string memory _symbolProto, address _appManagerAddress) external appAdministratorOnly(_appManagerAddress) initializer {
        __ERC20_init(_nameProto, _symbolProto); 
        __ERC20Burnable_init();
        __Ownable_init();
        __ERC20Permit_init(_nameProto);
        __UUPSUpgradeable_init();
        _initializeProtocol(_appManagerAddress);
    }

    /**
     * @dev Private Initializer sets the the App Manager Address
     * @param _appManagerAddress Address of App Manager
     */
    function _initializeProtocol(address _appManagerAddress) private onlyInitializing {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        emit AD1467_NewTokenDeployed(_appManagerAddress);
    }

    /**
     * @dev Function is required for UUPSUpgradeable
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Function mints new tokens to caller.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * @param to Address of recipient
     * @param amount Number of tokens to mint 
     */
    function mint(address to, uint256 amount) public appAdministratorOnly(appManagerAddress) {
        _mint(to, amount);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param amount number of tokens to be transferred
     */
    // slither-disable-next-line calls-loop
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        /// Rule Processor Module Check
        if (handlerAddress != address(0x0)) {
            require(IProtocolTokenHandler(handlerAddress).checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        }   
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}
