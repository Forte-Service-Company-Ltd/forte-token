# Deploying the Protocol Token 
[![Project Version][version-image]][version-url]

## Utilize the Protocol Token Deployment Script 

The protocol token deployment script requires the .env file addresses to be set prior to deployment. The Rule Processor Diamond, Application Manager, and Application Handler contracts should already be deployed to the chain you wish to deploy to. Run the following command from the root of the repo to deploy:

```bash
forge script script/Deploy_ProtocolToken.s.sol --ffi --broadcast
```

(add the --rpc-url argument to the end of each of the forge commands to point the scripts to the chain you would like to deploy on)

Ensure you record the the address of your token and proxy from the transaction receipt!

[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/pacman