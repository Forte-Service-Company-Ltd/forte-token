## forte-token

Upgradeable token solution for cross platform gaming liquidity. 

### Deployment with FREV1 enabled 

Deployment can be done by doing the following:
1. Checkout [Forte Rules Engine v1](https://github.com/thrackle-io/forte-rules-engine-v1.git)
   1. Checkout branch: SE-1373-Deploy-Forte-Token-to-Eth-Sepolia-and-test
2. Set the following variables in the .env file. All of these addresses are required for FREV1 asset deployment.
      1. ETH_RPC_URL
         1. `This is the URL of the deployment chain`
      2. RULE_PROCESSOR_DIAMOND
         1. `This is the address of the FREV1 Rule Processor`
      3. DEPLOYMENT_OWNER
         1. `This is the address that will be the initial owner of the FREV1 assets`
      4. DEPLOYMENT_OWNER_KEY
         1. `This is the private key for the Deployment Owner`
      5. APP_ADMIN
         1. `This is the Application Administrator for the FREV1 assets`
      6. APP_ADMIN_PRIVATE_KEY
         1. `This is the Application Administrator private key`
      7. RULE_ADMIN
         1. `This is the Rule Administrator for the FREV1 assets. It is used to create/enable/disable rules for the application`
      8. RULE_ADMIN_PRIVATE_KEY
         1. `This is the Rule Adminstrator private key`
   
   NOTE: DEPLOYMENT_OWNER, APP_ADMIN, and RULE_ADMIN may all be the same address.

3. Open a terminal
4. Source the .env 

```
   source .env
```

5. Deploy an AppManager and ERC20Handler for the token 

```
   sh script/clientScripts/DeployForForteToken.sh 
```

6. Pull the following addresses from the .env
   1. APPLICATION_APP_MANAGER
   2. APPLICATION_ERC20_HANDLER_ADDRESS
7. Checkout [Forte-Token](https://github.com/thrackle-io/forte-token.git)
8. Create .env in the root directory and copy the contents of env.forte into .env
9. Set the following variables in the .env 
   1. ETH_RPC_URL
      1. `This is the URL of the deployment chain`
   2. DEPLOYMENT_OWNER
      1. `This is the address of that will be the initial owner of the Forte Token contracts`
   3. DEPLOYMENT_OWNER_KEY
      1. `This is the private key of the Deployment Owner`
   4. MINTER_ADMIN
      1. `This is the address that will be given minting permissions with the Forte Token`
   5. MINTER_ADMIN_KEY
      1. `This is the private key of the Minter Admin`
   6. PROXY_OWNER_ADDRESS   
      1. `This is the address that will be the owner Forte Token proxy contract. It must be separate from other admins since it will never be passed through to access the token's standard logic.`
   7. FRE_APP_ADMIN
      1. `This is the FREV1 Application Administrator used prior`
   8. FRE_APP_ADMIN_PRIVATE_KEY
      1. `This is the Application Administrator private key`
   9.  FRE_RULE_ADMIN
       1. `This is the FREV1 Rule Administrator used prior`
   10. FRE_RULE_ADMIN_PRIVATE_KEY
       1.  `This is the private key for the Rule Administrator`
   11. FRE_TREASURY_1_ADMIN(must be the same as MINTER_ADMIN)
       1.  `This is the FREV1 Treasury admin account. It will bypass all configured rules and should be the same as the Minter Admin`
   12. FRE_TREASURY_1_ADMIN_PRIVATE_KEY
       1.  `This is the private key for the FREV1 Treasury Admin`
   13. FRE_TREASURY_2_ADMIN
       1.  `This is a second FREV1 Treasury Admin account. It will also bypass all configured rules.`
   14. RULE_PROCESSOR_DIAMOND
       1.  `This is the address of the FREV1 Rule Processor`
   15. APPLICATION_APP_MANAGER
       1.  `This is the address of the FREV1 Application Manager`
   16. APPLICATION_ERC20_HANDLER_ADDRESS
       1.  `This is the address of the FREV1 ERC20 Token Handler`

   NOTE: DEPLOYMENT_OWNER, MINTER_ADMIN, FRE_APP_ADMIN, FRE_RULE_ADMIN, and FRE_TREASURY_1_ADMIN may all be the same address. PROXY_OWNER_ADDRESS **must** be a different address.

10.  Source the .env 

```
   source .env
```

11.  Invoke the token creation/setup script
   
```
   sh script/deployment/DeployForteTokenAndConfig.sh
```

    1. The script will do the following:
       1. Deploy Forte Token
       2. Connect Forte Token to FRE
       3. Setup Admins in FRE and pause the token for non-treasurers
 12. In order to test the deployment, do the following:
    1. set SKIP_FORTE_TOKEN_TESTS=false
        
```
  forge test --match-contract ForteTokenTest --fork-url $ETH_RPC_URL -vvv
```

## Licensing

The primary license for Forte Token is the MIT License, see [`LICENSE`](./LICENSE). 