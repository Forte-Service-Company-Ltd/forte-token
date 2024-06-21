# Wave Token 
[![Project Version][version-image]][version-url]

## Purpose 
Wave is an ERC20 Upgradeable token and allows for the logic contract to be updated overtime. Wave token will utilize existing rules protocol architecure: the asset handler, application manager and handler, and the rule processor diamond. Wave token uses Access Control Upgradeable for the admin roles that guard certain functions within the token.

[Token Information](./WAVE.md#token-information)    

[Token Permissions](./WAVE.md#token-permissions)

## Deploying Wave Token 
[![Project Version][version-image]][version-url]

### Utilize the Wave Token Deployment Script 

The Wave token deployment script requires the .env file addresses to be set prior to deployment. The Rule Processor Diamond, Application Manager, and Application Handler contracts should already be deployed to the chain you wish to deploy to. Run the following command from the root of the repo to deploy:

```bash
sh script/deployTokens.sh
```

You will be prompted whether or not you would like the script to automatically connect the token to the protocol using 
Protocol addressess in the .env file (RULE_PROCESSOR_DIAMOND, APPLICATION_APP_MANAGER and APPLICATION_ERC20_HANDLER_ADDRESS)

### Deployment Environment Variables

The following environment variables need to be populated in the .env file in order to conduct a successful deployment:

DEPLOYMENT_OWNER - The address that will be used to deploy the contracts
DEPLOYMENT_OWNER_KEY - Private key of the deployment owner
MINTER_ADMIN - The address that will be able to mint the token
MINTER_ADMIN_KEY - Private key of the minter admin
PROXY_OWNER - The address that will serve as the owner for the proxy (must differ from the other two addresses)
PROXY_OWNER_KEY - Private key of the proxy owner

CURRENT_DEPLOYMENT - should be set to NATIVE before running the deployment script
NATIVE_CHAIN_RPC_URL - should point to the rpc url for the native chain (static urls are provided in the .env file for convenience)
FOREIGN_CHAIN_RPC_URL - should point to the rpc url for the foreign chain (static urls are provided in the .env file for convenience)

The following environment variables only need to be filled out if you're having the script connect the tokens to the protocol automatically during deployment:

TRON_DEPLOYMENT_OWNER - The address of the deployment owner for the protocol
TRON_DEPLOYMENT_OWNER_KEY - Private key of the protocol deployment owner
TRON_APP_ADMIN - The address of the protocol app admin
TRON_APP_ADMIN_KEY - Private key of the protocol app admin
RULE_PROCESSOR_DIAMOND - Address of the Rule Processor Diamond on the native chain
APPLICATION_APP_MANAGER - Address of the App Manager on the native chain
APPLICATION_ERC20_HANDLER_ADDRESS - Address of the token handler on the native chain
FOREIGN_RULE_PROCESSOR_DIAMOND - Address of the Rule Processor Diamond on the foreign chain
FOREIGN_APPLICATION_APP_MANAGER - Address of the App Manager on the foreign chain
FOREIGN_APPLICATION_ERC20_HANDLER_ADDRESS - Address of the token handler on the foreign chain

[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/pacman