// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
// deprecated import left to preserve storage layout
import "src/legacy_interfaces/IProtocolTokenHandler.sol";
// deprecated import left to preserve storage layout
import "src/legacy_interfaces/IProtocolToken.sol";
import "forte-rules-engine/client/IRulesEngine.sol";

/**
 * @title ERC20 Upgradable Protocol Token Contract
 * @author @ShaneDuncan602, @TJ-Everett, @VoR0220, @Palmerg4
 * @notice Protocol ERC20 Upgradeable to provide liquidity for Web3 economies
 */

contract ProtocolTokenv2 is Initializable, UUPSUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PermitUpgradeable, OwnableUpgradeable, AccessControlUpgradeable, IProtocolToken  {
    
    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // Variable is used to store the forte-rules-engine address
    address public handlerAddress;
    // deprecated variable left to preserve storage layout
    IProtocolTokenHandler handler;
    event Paused(address account);
    event Unpaused(address account);
    uint256[48] reservedStorage;
    bool private _paused;  

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
     * @dev Function sets the Forte Rules Engine address. This function was adapted from Forte Rules Engine V1 integration
     * @notice When the address is not address(0), FRE is connected.
     * @param _rulesEngineAddress Address of FRE
     */
    function connectHandlerToToken(address _rulesEngineAddress) onlyRole(TOKEN_ADMIN_ROLE) external{
        handlerAddress = _rulesEngineAddress;
    }
    
    /**
     * @dev Function returns the Forte Rules Engine address. This function was adapted from Forte Rules Engine V1 integration
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function transfers tokens to a user from the msg.sender
     * @param to Address of receiver
     * @param amount Number of tokens to transfer 
     */
    function transfer(address to, uint256 amount) public virtual override checksPoliciesERC20TransferBefore(to, amount, balanceOf(msg.sender), balanceOf(to), block.timestamp) returns(bool){
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override checksPoliciesERC20TransferFromBefore(from, to, amount, balanceOf(from), balanceOf(to), block.timestamp)
        returns (bool)
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Upgradeable) {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }

     /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function pause() external onlyRole(TOKEN_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(TOKEN_ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual {
        _paused = false;
        emit Unpaused(_msgSender());
    }
  
    /**
     * @notice Modifier for checking policies before executing the `transferFrom` function.
     * @dev Calls the `_checksPoliciesERC20TransferFrom` function to evaluate policies.
     * @param from The sending address.
     * @param to The receiving address.
     * @param value The amount to transfer.
     * @param balanceFrom The sender's balance before the transfer.
     * @param balanceTo The receiver's balance before the transfer.
     * @param blockTime The current block timestamp.
     */
    modifier checksPoliciesERC20TransferFromBefore(address from, address to, uint256 value, uint256 balanceFrom, uint256 balanceTo, uint256 blockTime) {
        _checksPoliciesERC20TransferFrom(from, to, value, balanceFrom, balanceTo, blockTime);
        _;
    }

   /**
     * @notice Modifier for checking policies before executing the `transfer` function.
     * @dev Calls the `_checksPoliciesERC20Transfer` function to evaluate policies.
     * @param to The receiving address.
     * @param value The amount to transfer.
     * @param balanceFrom The sender's balance before the transfer.
     * @param balanceTo The receiver's balance before the transfer.
     * @param blockTime The current block timestamp.
     */
    modifier checksPoliciesERC20TransferBefore(
        address to,
        uint256 value,
        uint256 balanceFrom,
        uint256 balanceTo,
        uint256 blockTime
    ) {
        _checksPoliciesERC20Transfer(to, value, balanceFrom, balanceTo, blockTime);
        _;
    }

    /**
     * @notice Calls the Rules Engine to evaluate policies for an ERC20 `transfer` operation.
     * @dev Encodes the parameters and invokes the `_invokeRulesEngine` function.
     * @param _to The receiving address.
     * @param _value The amount to transfer.
     * @param _balanceFrom The sender's balance.
     * @param _balanceTo The receiver's balance.
     * @param _blockTime The current block timestamp.
     */
    function _checksPoliciesERC20Transfer(
        address _to,
        uint256 _value,
        uint256 _balanceFrom,
        uint256 _balanceTo,
        uint256 _blockTime
    ) internal {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, _to, _value, msg.sender, _balanceFrom, _balanceTo, _blockTime);
        _invokeRulesEngine(encoded);
    }

    /**
     * @notice Calls the Rules Engine to evaluate policies for an ERC20 `transferFrom` operation.
     * @dev Encodes the parameters and invokes the `_invokeRulesEngine` function.
     * @param _from The sending address.
     * @param _to The receiving address.
     * @param _value The amount to transfer.
     * @param _balanceFrom The sender's balance.
     * @param _balanceTo The receiver's balance.
     * @param _blockTime The current block timestamp.
     */
    function _checksPoliciesERC20TransferFrom(
        address _from,
        address _to,
        uint256 _value,
        uint256 _balanceFrom,
        uint256 _balanceTo,
        uint256 _blockTime
    ) internal {
        bytes memory encoded = abi.encodeWithSelector(msg.sig, _to, _from, _value, msg.sender, _balanceFrom, _balanceTo, _blockTime);
        _invokeRulesEngine(encoded);
    }

    /**
     * @notice Set the Calling Contract Admin.
     */
    function setCallingContractAdmin(address _callingContractAdmin) public onlyRole(TOKEN_ADMIN_ROLE) {
        IRulesEngine(handlerAddress).grantCallingContractRole(address(this), _callingContractAdmin);
    }

    /**
     * @notice Invokes the Rules Engine to evaluate policies.
     * @dev This function calls the `checkPolicies` function of the Rules Engine.
     *      The `encoded` parameter must be properly encoded using `abi.encodeWithSelector`.
     *      Example: `bytes memory encoded = abi.encodeWithSelector(msg.sig, to, value, msg.sender);`
     * @param _encoded The encoded data to be passed to the Rules Engine.
     */
    function _invokeRulesEngine(bytes memory _encoded) internal {
        // if the address is address(0), skip the policy check.
        if (handlerAddress != address(0)){
            IRulesEngine(handlerAddress).checkPolicies(_encoded);
        }
    }
}
