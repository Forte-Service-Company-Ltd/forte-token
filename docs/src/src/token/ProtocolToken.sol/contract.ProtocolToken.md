# ProtocolToken
[Git Source](https://github.com/Forte-Service-Company-Ltd/forte-token/blob/8c2cfc24c58aaa71a578fa8d6ded19ef06315058/src/token/ProtocolToken.sol)

**Inherits:**
Initializable, UUPSUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PermitUpgradeable, OwnableUpgradeable, AccessControlUpgradeable, IProtocolToken

**Author:**
@ShaneDuncan602, @TJ-Everett, @VoR0220, @Palmerg4

Protocol ERC20 Upgradeable to provide liquidity for Web3 economies


## State Variables
### TOKEN_ADMIN_ROLE

```solidity
bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
```


### MINTER_ROLE

```solidity
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


### handlerAddress

```solidity
address public handlerAddress;
```


### handler

```solidity
IProtocolTokenHandler handler;
```


### reservedStorage

```solidity
uint256[48] reservedStorage;
```


## Functions
### constructor

**Note:**
oz-upgrades-unsafe-allow: constructor


```solidity
constructor();
```

### initialize

This function should be called in an "atomic" deploy script when deploying an ERC20Upgradeable contract.
"Front Running" is possible if this function is called individually after the ERC20Upgradeable proxy is deployed.
It is critical to ensure your deploy process mitigates this risk.

*Initializer sets the name, symbol and the App Manager Address*


```solidity
function initialize(string memory _nameProto, string memory _symbolProto, address _tokenAdmin) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nameProto`|`string`|Name of the Token|
|`_symbolProto`|`string`|Symbol for the Token|
|`_tokenAdmin`|`address`|address to be granted the token admin role for the Token|


### _authorizeUpgrade

*Function is required for UUPSUpgradeable*


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### mint

Add appAdministratorOnly modifier to restrict minting privilages

*Function mints new tokens to caller.*


```solidity
function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`amount`|`uint256`|Number of tokens to mint|


### burn

Add appAdministratorOnly modifier to restrict burning privilages

*Function burns tokens from a user, presumably for cross chain transfer*


```solidity
function burn(address from, uint256 amount) public onlyRole(MINTER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Address of burner|
|`amount`|`uint256`|Number of tokens to burn|


### _beforeTokenTransfer

*Function called before any token transfers to confirm transfer is within rules of the protocol*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|sender address|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to be transferred|


### getHandlerAddress

*This function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external onlyRole(TOKEN_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


