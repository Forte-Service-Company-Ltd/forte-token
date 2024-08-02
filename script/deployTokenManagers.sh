#!/bin/bash

echo "################################################################"
echo Transaction output will be broadcasted in the broadcast folder under the deployTokenManager.s.sol folder.
echo Search for the appropriate ChainID to see the results of each transaction.
echo "################################################################"
echo

OUTPUTFILE="test_env"

ENV_FILE=".env"
source $ENV_FILE

echo "################################################################"
echo Deploy an Axelar TokenManager to the native chain and the foreign chain
forge script script/deployTokenManager.s.sol --ffi -vvv --non-interactive --rpc-url $NATIVE_CHAIN_RPC_URL --broadcast --gas-price 20
echo "################################################################"
