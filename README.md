## forte-token

Upgradeable token solution for cross platform gaming liquidity. 

### Deployment with FREV1 enabled 

Deployment can be done by doing the following:
1. Checkout [Forte Rules Engine v1](https://github.com/thrackle-io/forte-rules-engine-v1.git)
   1. Checkout branch: SE-1373-Deploy-Forte-Token-to-Eth-Sepolia-and-test
2. Set the following variables in the .env file
      1. ETH_RPC_URL
      2. RULE_PROCESSOR_DIAMOND
      3. DEPLOYMENT_OWNER
      4. DEPLOYMENT_OWNER_KEY
      5. APP_ADMIN
      6. APP_ADMIN_PRIVATE_KEY
      7. RULE_ADMIN
      8. RULE_ADMIN_PRIVATE_KEY
3. Open a terminal
4. Source the .env 

```
   source .env
```

5. Deploy an AppManager and ERC20Handler for the token 

```
   sh script/clientScripts/DeployForForteToken.sh 
```

4. Pull the following addresses from the .env
   1. APPLICATION_APP_MANAGER
   2. APPLICATION_ERC20_HANDLER_ADDRESS
5. Checkout [Forte-Token](https://github.com/thrackle-io/forte-token.git)
6. Create .env in the root directory and copy the contents of env.forte into .env
7. Set the following variables in the .env 
   1. ETH_RPC_URL
   2. DEPLOYMENT_OWNER
   3. DEPLOYMENT_OWNER_KEY
   4. MINTER_ADMIN
   5. MINTER_ADMIN_KEY
   6. PROXY_OWNER_ADDRESS   
   7. FRE_APP_ADMIN
   8. FRE_APP_ADMIN_PRIVATE_KEY
   9. FRE_RULE_ADMIN
   10. FRE_RULE_ADMIN_PRIVATE_KEY
   11. FRE_TREASURY_1_ADMIN(must be the same as MINTER_ADMIN)
   12. FRE_TREASURY_1_ADMIN_PRIVATE_KEY
   13. FRE_TREASURY_2_ADMIN
   14. RULE_PROCESSOR_DIAMOND
   15. APPLICATION_APP_MANAGER
   16. APPLICATION_ERC20_HANDLER_ADDRESS
8.  Source the .env 

```
   source .env
```

9.  Invoke the token creation/setup script
   
```
   sh script/deployment/DeployForteTokenAndConfig.sh
```

    1. The script will do the following:
       1. Deploy Forte Token
       2. Connect Forte Token to FRE
       3. Setup Admins in FRE and pause the token for non-treasurers
 8. In order to test the deployment, do the following:
    1. set SKIP_FORTE_TOKEN_TESTS=false
        
```
  forge test --match-contract ForteTokenTest --fork-url $ETH_RPC_URL -vvv
```

## Licensing

The primary license for Forte Token is the MIT License, see [`LICENSE`](./LICENSE). 