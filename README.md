## forte-token

Upgradeable token solution for cross platform gaming liquidity. 

### Deployment with FREV1 enabled 

Deployment can be done by doing the following:
1. Checkout Forte Rules Engine v1
2. Deploy an AppManager for the application
3. Deploy ERC20Handler for the token
4. Checkout Forte-Token repo
5. Create .env in the root directory and copy the contents of env.forte into .env
6. Set the following .env variables
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
7.  Invoke the token creation/setup script
    1.  sh script/deployment/DeployForteTokenAndConfig.sh
    2. The script will do the following:
       1. Deploy Forte Token
       2. Connect Forte Token to FRE
       3. Setup Admins in FRE and pause the token for non-treasurers
 8. In order to test the deployment, do the following:
    1. set SKIP_FORTE_TOKEN_TESTS=false
    2. 
    
    ```
        forge test --match-contract ForteTokenTest --fork-url $ETH_RPC_URL -vvv
    ```




Protocol Assets

RULE_PROCESSOR_DIAMOND=0xd0dce3e14af7ffb89537c5b97aafdaf337b842e4
APPLICATION_APP_MANAGER=0x750d7997c03f99cbc11044283e9274c8c42da925
APPLICATION_ERC20_HANDLER_ADDRESS
