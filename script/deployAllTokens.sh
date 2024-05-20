#!/bin/bash

echo "################################################################"
echo Transaction output will be located in transaction_output.txt
echo a env file will be created with all of the relevant address exports at .test_env
echo "################################################################"
echo

OUTPUTFILE="test_env"

ENV_FILE=".env"
source $ENV_FILE
echo "################################################################"
echo Deploy parent token to ETH mainnet
echo $ETH_RPC_URL
echo "################################################################"
echo
forge script script/deployTokens.s.sol --rpc-url $ETH_RPC_URL

echo "################################################################"
echo Deploy child token to Polygon
echo $POLYGON_RPC_URL
echo "################################################################"
echo
forge script script/deployTokens.s.sol --rpc-url $POLYGON_RPC_URL

echo "################################################################"
echo Deploy an Axelar TokenManager to ETH mainnet
echo $ETH_RPC_URL
echo "################################################################"