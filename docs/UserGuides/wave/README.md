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
forge script script/Deploy_WaveToken.s.sol --ffi --broadcast
```

add the --rpc-url argument to the end of each of the forge commands or export ETH_RPC_URL=urlHere to point the script to the chain you would like to deploy on

Ensure you record the the address of your token and proxy from the transaction receipt!

[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/pacman