deployer address = freshly created Ethereum address

1. Set up the .env and run command:
   1. source .env
2. Deploy the AllowList contract using deployer address 
    ```
    forge script script/deployment/v2/1_Deploy_AllowList.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast
    source .env
    ```
3. Load the allowList contract using deployer address and transfer ownership to TAMS -- Script 2
    ```
    forge script script/deployment/v2/2_Load_AllowList.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast -vvvv
    source .env
    ```
4. Deploy the logic contract using the deployer address -- Script 3
    ```
    forge script script/deployment/v2/3_Deploy_LogicContract.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast -vvvv
    source .env
    ```
5. Navigate to the Quickstart repo and create the policy using the deployer address
6. Set the PolicyID in the forte-token/.env
7. Propose TAMS as a new PolicyAdmin -- Script 4
   ```
   forge script script/deployment/v2/4_Propose_PolicyAdmin.s.sol --ffi --fork-url $ETH_RPC_URL --broadcast -vvvv
   ```

8. MS commands, they must be run from the SAFE UI:
	a. CAMS--Upgrade to the logic contract `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        upgradeTo(address) $LOGIC_CONTRACT
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "upgradeTo(address)" $LOGIC_CONTRACT
        ```
	b. TAMS--Set the TAMS as CallingContractAdmin `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        setCallingContractAdmin(address) 0x8faa75C89558FC4082740524475c7933D9716530
        ```
        Using GUI with calldata only. Then put this into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        0xd51758450000000000000000000000008faa75c89558fc4082740524475c7933d9716530
        ```
    
	c. TAMS--Apply the policy `Forte Rules Engine Contract`
        Using the SAFE Transaction Builder GUI
        ```
        applyPolicy(address,uint256[]) 0x9a559e0c7a071aFcf85B2F379201F11F8fF9257D [$POLICY_ID]
        ```

	d. TAMS--Change the handlerAddress to v2 `Forte Token Contract`
        Using the SAFE Transaction Builder GUI
        ```
        connectHandlerToToken(address) $FORTE_RULES_ENGINE
        ```
        Using GUI with calldata only(fill in the $ variables manually). Then run the cast command in a terminal. Then put that into the calldata of the SAFE Transaction Builder GUI with the `Custom Data` toggled on
        ```
        cast calldata "connectHandlerToToken(address)" $FORTE_RULES_ENGINE
        ```