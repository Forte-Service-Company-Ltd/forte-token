source .env
forge script script/deployment/1_Deploy_Token.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
source .env
forge script script/deployment/2_Connect_TokenToProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY
source .env
forge script script/deployment/3_Setup_TokenForProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20 --verify --verifier etherscan --etherscan-api-key $ETHERSCAN_API_KEY