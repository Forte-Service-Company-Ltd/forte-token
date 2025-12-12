# Token Upgrade Deployment Guide

> **Note:** Deployer address = freshly created Ethereum address

## Phase 1: Initial Setup and Contract Deployment

### Step 1: Environment Setup
1. Set up the `.env` and run command:
   ```bash
   source .env
   ```

### Step 2: Deploy AllowList Contract
Deploy the AllowList contract using deployer address:
```bash
forge script script/deployment/v2/1_Deploy_KYC.s.sol \
    --ffi \
    --rpc-url $ETH_RPC_URL \
    --broadcast \
    --verify \
    --verifier etherscan \
    --etherscan-api-key $API_KEY

source .env
```

### Step 3: Load AllowList Contract
Load the allowList contract using deployer address and transfer ownership to TAMS:
```bash
forge script script/deployment/v2/2_Load_AllowList.s.sol \
    --ffi \
    --rpc-url $ETH_RPC_URL \
    --broadcast \
    -vvvv \
    --verify \
    --verifier etherscan \
    --etherscan-api-key $API_KEY

source .env
```

### Step 4: Deploy Logic Contract
Deploy the logic contract using the deployer address:
```bash
forge script script/deployment/v2/3_Deploy_LogicContract.s.sol \
    --ffi \
    --rpc-url $ETH_RPC_URL \
    --broadcast \
    -vvvv \
    --verify \
    --verifier etherscan \
    --etherscan-api-key $API_KEY

source .env
```

## Phase 2: Multi-Signature Wallet Operations

### Step 5: SAFE Wallet Operations
Navigate to the SAFE Wallet and use the transaction builder. Enter the address and the function list will display:

#### 5.1 CAMS - Token Proxy Contract Upgrade
**Upgrade the logic contract** `Forte Token Contract`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
upgradeTo(address) $LOGIC_CONTRACT
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "upgradeTo(address)" $LOGIC_CONTRACT
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "upgradeTo(address)" $LOGIC_ADDRESS \
       --rpc-url $ETH_RPC_URL \
       --private-key $CAMS_PK
   ```

#### 5.2 TAMS - Pause Token
**Pause the token** `Forte Token Contract`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
pause()
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "pause()"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "pause()" \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

## Phase 3: Rules Engine Setup

### Step 6: Clone FRE-Quickstart Repository (CHECK DEPLOYER ETH BALANCE)
1. Open a fresh workspace and clone the repository:
   ```bash
   git clone https://github.com/Forte-Service-Company-Ltd/fre-quickstart.git
   ```

### Step 7: Checkout Configuration Branch
```bash
git checkout token-upgrade
```

### Step 8: Setup Quickstart Environment
Run these commands from a fresh terminal within the root folder:
```bash
npm install
forge install
```

### Step 9: Create Environment Configuration
1. Create a fresh `.env` in the root folder:
   ```bash
   cp .env.sample .env
   ```

2. Add the following configuration:
   - `RPC_URL=https://eth-mainnet.g.alchemy.com/v2/uXaRsW_z8fz5jj2BORAkOV-i_dyYtd-e`
   - `RULES_ENGINE_ADDRESS=0x58888416d50ce709AEcc0a8c7b27C7ECa549Ff99`
   - `NETWORK=ethereum`
   - `PRIV_KEY=your-private-key-here` (DEPLOYMENT_OWNER_KEY)
   - `USER_ADDRESS=your-address-here` (DEPLOYMENT_OWNER)

3. Source the environment:
   ```bash
   source .env
   ```

### Step 10: Configure Policy JSON
Fill in the `policy.json` with the following KYC oracle addresses:
- `isKYCd_to(ALLOWLIST_ADDRESS)`
- `isKYCd_from(ALLOWLIST_ADDRESS)`
- `isKYCd_to2(ALLOWLIST_ADDRESS)`
- `isKYCd_from2(ALLOWLIST_ADDRESS)`

### Step 11: Create Policy Using Quickstart
1. Create the policy:
   ```bash
   npx tsx index.ts setupPolicy policy.json
   ```

2. Note the Policy ID created and load it as an environment variable:
   ```bash
   export POLICY_ID=<enter policy id here>
   npx tsx index.ts updatePolicy policyAdd.json $POLICY_ID
   ```

### Step 12: Update Environment
Navigate back to forte-token repo, add the POLICY_ID to the `.env` and source it:
```bash
source .env
```

### Step 13: Propose Policy Admin
Propose TAMS as a new PolicyAdmin:
```bash
forge script script/deployment/v2/4_Propose_PolicyAdmin.s.sol \
    --ffi \
    --rpc-url $ETH_RPC_URL \
    --broadcast \
    -vvvv
```

## Phase 4: Final Multi-Signature Operations

### Step 14: SAFE UI Commands
⚠️ **Important:** These commands must be run from the SAFE UI. Go to the transaction builder, enter the address, and the function list will display:

#### 14.1 TAMS - Accept Policy Admin Role
**Accept the policy admin role by calling a function in FRE $FORTE_RULES_ENGINE_ADDRESS**

**Option A: Using SAFE Transaction Builder GUI**
```solidity
confirmNewPolicyAdmin(uint256)
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "confirmNewPolicyAdmin(uint256)" $POLICY_ID
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $FORTE_RULES_ENGINE_ADDRESS "confirmNewPolicyAdmin(uint256)" $POLICY_ID \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

#### 14.2 TAMS - Set FRE Address
**Set the FRE Address within the token** `Forte Token Contract`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
connectHandlerToToken(address) $FORTE_RULES_ENGINE_ADDRESS
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "connectHandlerToToken(address)" $FORTE_RULES_ENGINE_ADDRESS
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "connectHandlerToToken(address)" $FORTE_RULES_ENGINE_ADDRESS \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

#### 14.3 TAMS - Set CallingContractAdmin
**Set the TAMS as CallingContractAdmin** `Forte Token Contract`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
setCallingContractAdmin(address) 0x8faa75C89558FC4082740524475c7933D9716530
```

**Option B: Using calldata with Custom Data toggle**
Calldata: `0xd51758450000000000000000000000008faa75c89558fc4082740524475c7933d9716530`

Alternative direct send (for testing):
```bash
cast send $TOKEN_ADDRESS "setCallingContractAdmin(address)" $TAMS \
    --rpc-url $ETH_RPC_URL \
    --private-key $TAMS_PK
```

#### 14.4 TAMS - Add Approved Subscriber
**Add the TAMS as an approved subscriber** via `Forte Rules Engine`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
addClosedPolicySubscriber(uint256 policyId, address subscriber) $POLICY_ID $TAMS
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "addClosedPolicySubscriber(uint256, address)" $POLICY_ID $TAMS
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $FORTE_RULES_ENGINE_ADDRESS "addClosedPolicySubscriber(uint256, address)" $POLICY_ID $TAMS \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

#### 14.5 TAMS - Apply Policy
**Apply the policy to v2** `Forte Token Contract` via `Forte Rules Engine`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
applyPolicy(address,uint256[]) $TOKEN_ADDRESS [$POLICY_ID]
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "applyPolicy(address,uint256[])" $TOKEN_ADDRESS "[$POLICY_ID]"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $FORTE_RULES_ENGINE_ADDRESS "applyPolicy(address,uint256[])" $TOKEN_ADDRESS "[$POLICY_ID]" \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

#### 14.6 TAMS - Unpause Token
**Unpause the token** `Forte Token Contract`

**Option A: Using SAFE Transaction Builder GUI**
```solidity
unpause()
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "unpause()"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "unpause()" \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

## Phase 5: Testing (Optional)

### Step 15: Fork Testing
Run fork tests to ensure that the token is functioning properly:

1. Set these values in the `.env`:
   ```bash
   SKIP_FORTE_TOKEN_TESTS=false
   FORK_TEST=true
   ALLOWLIST_OWNER=(set this to the TAMS)
   ```

2. Source the .env
   ```bash
   source .env
   ```

3. Run the tests(Ignore any compile errors from submodules in a state of flux):
   ```bash
   forge test --match-contract ForteRulesEngineV2TestDeploy --fork-url $ETH_RPC_URL
   ```

---

# Miscellaneous Commands

## KYC Address Management

### 1. Add to KYC List (Single Address)
**Must be done from the TAMS**

**Option A: Using SAFE Transaction Builder GUI**
```solidity
allow(address account)
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "allow(address)"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "allow(address)" $ADDRESS_TO_ALLOW \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

### 2. Add to KYC List (Batch)
**Must be done from the TAMS**

**Option A: Using SAFE Transaction Builder GUI**
```solidity
allowBatch(address[] calldata accounts)
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "allowBatch(address[])"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "allowBatch(address[])" "[address1,address2,...]" \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

### 3. Remove from KYC List (Batch)
**Must be done from the TAMS**

**Option A: Using SAFE Transaction Builder GUI**
```solidity
disallowBatch(address[] calldata accounts)
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "disallowBatch(address[])"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "disallowBatch(address[])" "[address1,address2,...]" \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

### 4. Remove from KYC List (Single Address)
**Must be done from the TAMS**

**Option A: Using SAFE Transaction Builder GUI**
```solidity
disallow(address account)
```

**Option B: Using calldata with Custom Data toggle**
1. Generate calldata:
   ```bash
   cast calldata "disallow(address)"
   ```
2. Alternative direct send (for testing):
   ```bash
   cast send $TOKEN_ADDRESS "disallow(address)" $ADDRESS_TO_DISALLOW \
       --rpc-url $ETH_RPC_URL \
       --private-key $TAMS_PK
   ```

## Tracker Management

### 5. Add New Addresses to Trackers (S, E, M, T, STK)

This process involves creating complex calldata that can be used in the multisig.

> **Note:** This will automatically create the calldata for Tracker 2 as well.

#### Setup Process:

1. **Set in the `.env`:**
   - `POLICY_ID`
   - `TRACKER_INDEX=1`
   - `KEY_TYPE=0`
   - `VALUE_TYPE=1`
   - `KEYS` (comma separated list of addresses)
   - `VALUES` (comma separated list of types)

2. **Run the helper script:**
   ```bash
   sh script/deployment/v2/load_trackers_calldata.sh
   ```

3. **This will generate 2 calldata strings:** TRACKER 1 and TRACKER 2

#### Execution Process:

4. Navigate to the **TAMS multisig**
5. Go to the **Transaction Builder**
6. Enter the **Forte Rules Engine address**
7. Click the **`custom data`** button
8. Copy the **calldata for Tracker 1** into the `Data` box
9. Enter **`0`** for the `Eth Value`
10. Click the **`Create Batch`** button
11. Click the **`Simulate`** button to ensure transaction is valid
12. Click **`Send Batch`** and follow normal progression of multi-sig approval and execution
13. **Repeat the process for TRACKER 2 calldata** if present

> **Note:** If only adding STK addresses, TRACKER 2 calldata will not be present.