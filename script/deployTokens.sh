#!/bin/bash

echo "################################################################"
echo Transaction output will be broadcasted in the broadcast folder under the deployProtocolToken.s.sol folder.
echo Search for the appropriate ChainID to see the results of each transaction.
echo "################################################################"
echo

ENV_FILE=".env"
source $ENV_FILE
echo "################################################################"
echo Deploy parent token to ETH sepolia
echo "################################################################"
echo
forge script script/deployToken.s.sol --ffi -vvv --non-interactive --rpc-url sepolia_chain --broadcast --gasPrice 20

echo "################################################################"
echo Deploy child token to Base Sepolia 
echo "################################################################"
echo
forge script script/deployToken.s.sol --ffi -vvv --non-interactive --rpc-url base_sepolia_chain --broadcast --gasPrice 20
