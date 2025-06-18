source .env
forge script script/deployment/1_Deploy_Token.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20
source .env
forge script script/deployment/2_Connect_TokenToProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20
source .env
forge script script/deployment/3_Setup_TokenForProtocol.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20
# source .env
# forge script script/deployment/4_Mint_Token.s.sol --ffi -vvvv --rpc-url $ETH_RPC_URL --broadcast --gas-price 20