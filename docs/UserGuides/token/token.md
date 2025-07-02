# Token 
[![Project Version][version-image]][version-url]


## Table of Contents
- [Purpose](#purpose)
- [Ownership of Token](#ownership-of-token)
- [Token Information](#token-information)
- [Integration with Rule Processor Diamond](#integration-with-rule-processor-diamond)
- [Token Permissions](#token-permissions)
- [Proxy Pattern](#proxy-pattern)
- [Upgrading The Token](#upgrading-the-token)
- [Token Functionality](#token-functionality)
- [Testing Methodology](#testing-methodology)



## Purpose 
The token is an ERC20 Upgradeable token and allows for the logic contract to be updated overtime. The token will utilize existing rules protocol architecture: the asset handler, application manager and handler, and the rule processor diamond. The token uses Access Control Upgradeable for the admin roles that guard certain functions within the token.  


## Ownership of Token

The token will be owned by a multi-signature safe contract owned by the [Team](mailto:support@fortefoundation.io).

## Token Information
- Deployments: 
    - Ethereum Mainnet: <Mainnet Address>
    - Polygon POS: <Polygon Address> 
- Name: Forte 
- Symbol: FOR 
- Initial Minted Supply: 0 
- Total Supply: Uncapped (mintable/ burnable)
- Decimals: 18 
- Access Control Upgradeable RBAC Roles 

## Integration with Rule Processor Diamond 
The token utilizes the Rules Procotol `_checkAllRules()` hook in the `_beforeTokenTransfer()` of the token. The token will be connected to its own asset handler diamond. The [Token](../../../src/token/ProtocolToken.sol) contract inherits both the `IProtocolTokenHandler.sol` and `IProtocolERC20UMin.sol` interfaces.

The `IProtocolTokenHandler.sol` interface is for the token to call the `_checkAllRules()` hook. Once an asset handler diamond address has been connected to the token, any rules that are set to active within that asset handler diamond will be checked upon transfer of the token. 

## Token Permissions
The token utilizes the [Access Control Upgradeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/AccessControlUpgradeable.sol) for role based access controls.
The token has the following roles: 
```solidity
TOKEN_ADMIN 
MINTER
```
- `TOKEN_ADMIN` role can connect the token to an asset handler diamond.  
- `MINTER` role is the only role that is allowed to mint new tokens.

functions use the modifier:
```solidity
modifier onlyRole(bytes32 role)
```

## Proxy Pattern 

The token utilizes an Upgradeable Proxy Pattern that adheres to the [ERC1967 standard](https://eips.ethereum.org/EIPS/eip-1967). The [Token Proxy](../../../src/token/ProtocolTokenProxy.sol) is the proxy contract for the [Token](../../../src/token/ProtocolToken.sol). 

The Token Proxy will first check if the calling address is the admin for the contract. If the caller is not the admin, the call is then passed to the logic contract via a `delegateCall`. If the caller is the admin of the token proxy, they must call one of the functions within the Proxy contract and cannot call functions inside of the logic contract. Calls to the logic contract by the proxy admin will revert with "TransparentUpgradeableProxy: admin cannot fallback to proxy target". 

### Token Proxy Permissions 
The token proxy utilizes a proxy admin role set at contruction of the proxy contract. This address is passed into the constructor as an address parameter and granted the role of `admin` for the proxy. This role may be changed through the function: 

```solidity
function changeAdmin(address newAdmin) external virtual ifAdmin
```

This function is only callable by the current proxy admin via the ifAdmin modifier: 

```solidity
modifier ifAdmin() 
```

## Upgrading The Token 
### Logic Contract Upgrades
ERC20 Upgradeable allows for the Proxy address to point to a new logic contract. This is done by calling either the function: 
```solidity
function upgradeTo(address newImplementation) external ifAdmin
```
Or the function:
```solidity
function upgradeToAndCall(address newImplementation, bytes calldata data)  external payable ifAdmin
```
Both upgrade functions use the [ifAdmin](#token-permissions) modifier. 

### Asset Handler Upgrades
Connecting to a new asset handler is done by calling the function: 
```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) 
```
This function uses the [appAdministratorOnly](#token-permissions) modifier. 

### Application Manager Upgrades 
Connecting to a new Application manager is done through a two step verification process. First call the function: 
```solidity
function proposeAppManagerAddress(address _newAppManagerAddress)
```
This function uses the [appAdministratorOnly](#token-permissions) modifier. 

Then by calling the function: 
```solidity
function confirmAppManagerAddress() external
```

## Token Functionality 
### ERC20 Upgradeable Structure
The token inherits from multiple contracts: 
- ERC20 Upgreadeable
- Initializable 
- ERC20BurnableUpgradeable 
- OwnableUpgradeable 
- ERC20PermitUpgradeable 
- UUPSUpgradeable 
- ProtocolTokenCommonU 

### Standard ERC20 Token functions 
The token inherits and has all standard ERC20 functions as defined in the [ERC20 Upgreadeable](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/token/ERC20/ERC20Upgradeable.sol) contract. 

#### Testing Methodology 
[Testing](./ERC20_UPGRADEABLE_TESTING_METHODOLOGY.md) for the token's functionality and integration with the Rule Processor Diamond.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/Forte-Service-Company-Ltd/forte-token