# ERC20 Upgradeable Testing Methodology 
[![Project Version][version-image]][version-url]

## Purpose 
Outline of the functional testing for the ERC20 Upgradeable Wave token. 

A full test suite can be run with the following command: 

```c
forge test --ffi 
```

## Unit Tests 
Local [Unit Tests](../../../test/token/integration/ProtocolToken.t.sol) are set up in in the ProtocolToken.t.sol contract. This contract inherits from a ERC20UCommonTests.t.sol test file. 

Local unit testing runs the set up function with each test. Starting from a fresh state. 

ERC20 functionality was tested to ensure mint, burn and transfers work with the asset handler diamond, application manager and application handler. 

Rules are tested via creation, setting and testing rule parameters. Each rule is tested to ensure the rule do not revert when the parameters are not violated and revert when the parameters would be violated. 

## Fuzz Tests
Local [Fuzz Tests](../../../test/token/fuzz/ProtocolTokenFuzz.t.sol) are set up in the ProtocolTokenFuzz.t.sol contract.

Fuzz testing runs the set up function with each test. Starting from a fresh state.

ERC20 functionality is tested with randomness to ensure that edge cases are properly tested and result in intended behavior from the token. 

## Invariant tests 
[Invariant Tests](../../../test/token/invariants/ERC20UCommon.t.i.sol) are set up in the ERC20UCommon.t.i.sol contract. 

Invariant testing utilizes randomness and saves the state of the contract to ensure that functionality result in the intended behavior. Invariant testing will take the stated assertion of each test, then call other functions across the test suite to ensure that the assertion holds. 

ERC20 Upgradeable functions for mint, burn, transfer, total supply, and zero address checks are were all tested in [ERC20UBasic](../../../test/token/invariants/ERC20UBasic.t.i.sol) and [ERC20UMintBurn](../../../test/token/invariants/ERC20UMintBurn.t.i.sol). 

## Fork Tests 
Fork testing was conducted on two chains, Polygon Amoy testnet and Ethereum Sepolia testnet.    
[Amoy Fork Testing](../../../test/token/deployment/RuleProcessorIntegration.t.sol)  
[Sepolia Fork Testing](../../../test/token/deployment/ForkTestERC20U.t.sol)

Fork testing requires the `FORK_TEST` env bool be set to `"true"` and that a valid `RPC_URL` is set for each chain. 
NOTE: Both fork test environements will run when the flag is set to true, so a valid rpc url is required for each Amoy and Sepolia chains. 

Fork testing will take the state of the tested chain at the provided block time as well as the deployed addresses provided in the env. This allows for local testing and testing using anvil to run transactions that test with the state of that chain. 

Rule setting and processing as well as role based account controls are tested through the `ERC20UCommonTests.t.sol` file. This allows  for local testing and fork testing to maintain parity in the test suite. 

Token Bridge Testing was conducted on Ethereum Sepolia and Base Sepoia test nets. Tokens were minted on Base Sepolia and bridged to Eth Sepolia.    
[Token Bridge Testing](../../../test/token/deployment/integration/BridgeTokenTest.t.sol)







<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/pacman