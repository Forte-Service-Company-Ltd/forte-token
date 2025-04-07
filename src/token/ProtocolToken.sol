// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "rulesEngine/client/token/IProtocolTokenHandler.sol";
import "rulesEngine/client/token/IProtocolToken.sol";

/**
 * @title ERC20 Upgradable Protocol Token Contract
 * @author @ShaneDuncan602, @TJ-Everett, @VoR0220, @Palmerg4
 * @notice Protocol ERC20 Upgradeable to provide liquidity for Web3 economies
 */

contract ProtocolToken is Initializable, UUPSUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PermitUpgradeable, OwnableUpgradeable, AccessControlUpgradeable, IProtocolToken  {
    
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    address public handlerAddress;
    IProtocolTokenHandler handler;
    uint256[48] reservedStorage;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer sets the name, symbol and the App Manager Address
     * @notice This function should be called in an "atomic" deploy script when deploying an ERC20Upgradeable contract. 
     * "Front Running" is possible if this function is called individually after the ERC20Upgradeable proxy is deployed. 
     * It is critical to ensure your deploy process mitigates this risk.
     * @param _nameProto Name of the Token
     * @param _symbolProto Symbol for the Token
     * @param _tokenAdmin address to be granted the token admin role for the Token
     */
   function initialize(string memory _nameProto, string memory _symbolProto, address _tokenAdmin) external initializer {
        __ERC20_init(_nameProto, _symbolProto); 
        __ERC20Burnable_init();
        __Ownable_init();
        __ERC20Permit_init(_nameProto);
        __UUPSUpgradeable_init();
        _grantRole(TOKEN_ADMIN_ROLE, _tokenAdmin); 
        _setRoleAdmin(TOKEN_ADMIN_ROLE, TOKEN_ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, TOKEN_ADMIN_ROLE);
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
    function mint(address to, uint256 amount) onlyRole(MINTER_ROLE) public  {
        _mint(to, amount);
    }

    /**
     * @dev Function burns tokens from a user, presumably for cross chain transfer
     * @notice Add appAdministratorOnly modifier to restrict burning privilages
     * @param from Address of burner
     * @param amount Number of tokens to burn 
     */
    function burn(address from, uint256 amount) onlyRole(MINTER_ROLE) public {
        _burn(from, amount);
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
    function connectHandlerToToken(address _deployedHandlerAddress) external onlyRole(TOKEN_ADMIN_ROLE) {
        if (_deployedHandlerAddress == address(0)) revert("Handler Address Cannot Be Zero");
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}
