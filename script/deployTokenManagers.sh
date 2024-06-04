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
echo Deploy an Axelar TokenManager to ETH sepolia
echo $ETH_RPC_URL
forge script script/deployTokenManager.s.sol --ffi -vvv --non-interactive --rpc-url sepolia_chain --broadcast --gasPrice 20
echo "################################################################"


echo "################################################################"
echo Deploy an Axelar TokenManager to Base sepolia
echo $ETH_RPC_URL
forge script script/deployTokenManager.s.sol --ffi -vvv --non-interactive --rpc-url base_sepolia_chain --broadcast --gasPrice 20
echo "################################################################"

