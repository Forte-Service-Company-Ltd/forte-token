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
echo Deploy an Axelar TokenManager to ETH sepolia
echo $ETH_RPC_URL
forge script script/deployTokenManager.s.sol --fork-url sepolia_chain
echo "################################################################"


echo "################################################################"
echo Deploy an Axelar TokenManager to Base sepolia
echo $ETH_RPC_URL
forge script script/deployTokenManager.s.sol --fork-url base_sepolia_chain
echo "################################################################"

