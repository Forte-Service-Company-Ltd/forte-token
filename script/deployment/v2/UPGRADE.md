**deployer address = freshly created Ethereum address

1. Set up the .env and run command:
   1. source .env
2. Deploy the AllowList contract using deployer address 
    ```
    forge script script/deployment/v2/1_Deploy_KYC.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast
    source .env
    ```
3. Load the allowList contract using deployer address and transfer ownership to TAMS -- Script 2
    ```
    forge script script/deployment/v2/2_Load_AllowList.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast -vvvv
    source .env
    ```
4. Deploy the logic contract using the deployer address -- Script 3
    ```
    forge script script/deployment/v2/3_Deploy_LogicContract.s.sol --ffi --rpc-url $ETH_RPC_URL --broadcast -vvvv
    source .env
    ```
5. Navigate to the SAFE Wallet for the CAMS. Go to the transaction builder, enter in the address, and the function list will display:
	a. CAMS--Token Proxy Contract -- Upgrade the logic contract `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        upgradeTo(address) $LOGIC_CONTRACT
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "upgradeTo(address)" $LOGIC_CONTRACT
        ```
        ```
        cast send $TOKEN_ADDRESS "upgradeTo(address)" $LOGIC_ADDRESS --rpc-url $ETH_RPC_URL --private-key $PROXY_OWNER_KEY
        ```
    b. TAMS--Pause the token `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        pause() 
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "pause()"
        ```
        ```
        cast send $TOKEN_ADDRESS "pause()" --rpc-url $ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY       
        ```
6. Open a fresh workspace and clone the [FRE-Quickstart repo](https://github.com/Forte-Service-Company-Ltd/fre-quickstart.git). 
7. Checkout the configured FRE-Quickstart branch, `token-upgrade`
    ```
    git checkout token-upgrade
    ```
8. Set up the Quickstart environment. Run these from a fresh terminal within the root folder.
    ```
    npm install
    forge install

    RPC_URL=https://ethereum-sepolia-rpc.publicnode.com
    PRIV_KEY=0x79128f4e09cc8495e2f47d56a488ad37955b99a2c22e94928adee439e347abf8
    RULES_ENGINE_ADDRESS=0xd3f47489ba52d03f26f43b66a78d5e9002c1cf08
    
    cp .env.v2 .env
    source .env
    ```
9. Fill in the policy.json with the KYC oracle address and address designations.
10. Create the policy using the Quickstart
   ```
   npx tsx index.ts setupPolicy policy.json   
   ```   
   Take note of the Policy Id created
11. Navigate back to forte-token repo, add the POLICY_ID to the .env and 
    ```
    source .env
    ```
12. Propose TAMS as a new PolicyAdmin -- Script 4
   ```
   forge script script/deployment/v2/4_Propose_PolicyAdmin.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast -vvvv
   ```

13. MS commands, they must be run from the SAFE UI. Go to the transaction builder, enter in the address, and the function list will display:
	1. TAMS--Accept the policy admin role by calling a function in FRE
        Using the SAFE Transaction Builder GUI
        ```
        confirmNewPolicyAdmin(uint256)
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "confirmNewPolicyAdmin(uint256)" $POLICY_ID
        ```
        ```
        cast send $FORTE_RULES_ENGINE_ADDRESS "confirmNewPolicyAdmin(uint256)" $POLICY_ID --rpc-url $ETH_RPC_URL --private-key $TAMS_PK
        ```
    2. TAMS--Set the FRE Address within the token `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        connectHandlerToToken(address) $FORTE_RULES_ENGINE_ADDRESS
        ```
        Using GUI with calldata only. Then put this into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "connectHandlerToToken(address)" $FORTE_RULES_ENGINE_ADDRESS
        ```
        ```
        cast send $TOKEN_ADDRESS "connectHandlerToToken(address)" $FORTE_RULES_ENGINE_ADDRESS --rpc-url $ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY
        ```
    3. TAMS--Set the TAMS as CallingContractAdmin `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        setCallingContractAdmin(address) 0x8faa75C89558FC4082740524475c7933D9716530
        ```
        Using GUI with calldata only. Then put this into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        0xd51758450000000000000000000000008faa75c89558fc4082740524475c7933d9716530
        ```
        ```
        cast send $TOKEN_ADDRESS "setCallingContractAdmin(address)" $TAMS --rpc-url $ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY
        ```
    4. TAMS--Add the TAMS as an approved subscriber via `Forte Rules Engine`
        Using the SAFE Transaction Builder GUI
        ```
        addClosedPolicySubscriber(uint256 policyId, address subscriber) $POLICY_ID $TAMS 
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "addClosedPolicySubscriber(uint256, address) $POLICY_ID $TAMS"
        ```
        ```
        cast send $FORTE_RULES_ENGINE_ADDRESS "addClosedPolicySubscriber(uint256, address)" $POLICY_ID $TAMS --rpc-url $ETH_RPC_URL --private-key $TAMS_PK
        ```
    5. TAMS--Apply the policy to v2 `Forte Token Contract` via `Forte Rules Engine`
        Using the SAFE Transaction Builder GUI
        ```
        applyPolicy(address,uint256[]) $TOKEN_ADDRESS [$POLICY_ID]
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "applyPolicy(address,uint256[])" $TOKEN_ADDRESS "[$POLICY_ID]"
        ```
        ```
        cast send $FORTE_RULES_ENGINE_ADDRESS "applyPolicy(address,uint256[])" $TOKEN_ADDRESS "[$POLICY_ID]" --rpc-url $ETH_RPC_URL --private-key $TAMS_PK
        ```
    6. TAMS--unpause the token `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        unpause() 
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "unpause()"
        ```
        ```
        cast send $TOKEN_ADDRESS "unpause()" --rpc-url $ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY       
        ```
14. Optional, run fork tests to ensure that the token is functioning properly.
    1.  Set these values in the .env
    ```
    SKIP_FORTE_TOKEN_TESTS=false
    FORK_TEST=true
    ```
    2. Run the test command:
    ```
    forge test --match-contract ForteRulesEngineV2TestDeploy --fork-url $ETH_RPC_URL
    ```