## 20250717 Separated out the verification of the Token, deployment and contract complexity caused intermittent failure using --verify --verifier in the deployment step

source .env
forge script script/deployment/1_Deploy_Token.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --etherscan-api-key $ETHERSCAN_API_KEY

# wait after the script for token tracker updates on chain (rather than using --slow)
echo "Waiting for token tracker updates on chain to catch up (60 seconds)"
sleep 60

# pick up the TOKEN_ADDRESS set in the previous script
source .env
# verify the token contract
forge verify-contract $TOKEN_ADDRESS src/token/ProtocolToken.sol:ProtocolToken --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY --watch --flatten                          

# connect the token to the protocol
forge script script/deployment/2_Connect_TokenToProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
source .env
forge script script/deployment/3_Setup_TokenForProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY