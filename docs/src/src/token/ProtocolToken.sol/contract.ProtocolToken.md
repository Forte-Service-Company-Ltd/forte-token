# ProtocolToken
[Git Source](https://github.com/thrackle-io/pacman/blob/077e8e97d564fd0f631cb54b1a570daaaa0671de/src/token/ProtocolToken.sol)

**Inherits:**
Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, UUPSUpgradeable, ProtocolTokenCommonU, ReentrancyGuard

**Author:**
@ShaneDuncan602, @TJ-Everett, @VoR0220, @Palmerg4

Protocol ERC20 Upgradeable for gaming liquidity


## State Variables
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
uint256[50] reservedStorage;
```


## Functions
### constructor


```solidity
constructor();
```

### initialize

This function should be called in an "atomic" deploy script when deploying an ERC20Upgradeable contract.
"Front Running" is possible if this function is called individually after the ERC20Upgradeable proxy is deployed.
It is critical to ensure your deploy process mitigates this risk.

*Initializer sets the name, symbol and the App Manager and Handler Address*


```solidity
function initialize(string memory _nameProto, string memory _symbolProto, address _appManagerAddress)
    external
    appAdministratorOnly(_appManagerAddress)
    initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nameProto`|`string`|Name of the Token|
|`_symbolProto`|`string`|Symbol for the Token|
|`_appManagerAddress`|`address`|Address of App Manager|


### _initializeProtocol

*Private Initializer sets the the App Manager Address*


```solidity
function _initializeProtocol(address _appManagerAddress) private onlyInitializing;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Address of App Manager|


### _authorizeUpgrade

*Function is required for UUPSUpgradeable*


```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner;
```

### mint

Add appAdministratorOnly modifier to restrict minting privilages

*Function mints new tokens to caller.*


```solidity
function mint(address to, uint256 amount) public appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Address of recipient|
|`amount`|`uint256`|Number of tokens to mint|


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

Rule Processor Module Check

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
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


