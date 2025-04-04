#!/bin/bash

echo "################################################################"
echo Transaction output will be broadcasted in the broadcast folder under the deployProtocolToken.s.sol folder.
echo Search for the appropriate ChainID to see the results of each transaction.
echo "################################################################"
echo

ENV_FILE=".env"
source $ENV_FILE
os=$(uname -a)
echo "Would you like to connect the token to the Rules Protocol during deployment? (y or n)"
read FULL_DEPLOYMENT
FULL_DEPLOYMENT=$(echo "$FULL_DEPLOYMENT" | tr '[:upper:]' '[:lower:]') 
while [ "y" != "$FULL_DEPLOYMENT" ] && [ "n" != "$FULL_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Would you like to connect the token to the Rules Protocol during deployment? (y or n)"
  read FULL_DEPLOYMENT
  FULL_DEPLOYMENT=$(echo "$FULL_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
done

echo "Would you like to deploy the token to the foreign chain? (y or n)"
read FOREIGN_DEPLOYMENT
FOREIGN_DEPLOYMENT=$(echo "$FOREIGN_DEPLOYMENT" | tr '[:upper:]' '[:lower:]') 
while [ "y" != "$FOREIGN_DEPLOYMENT" ] && [ "n" != "$FOREIGN_DEPLOYMENT" ] ; do
  echo
  echo "Not a valid answer (y or n)"
  echo "Would you like to connect the token to the Rules Protocol during deployment? (y or n)"
  read FOREIGN_DEPLOYMENT
  FOREIGN_DEPLOYMENT=$(echo "$FOREIGN_DEPLOYMENT" | tr '[:upper:]' '[:lower:]')  
done

if [ "$FULL_DEPLOYMENT" = "y" ]; then

    echo "################################################################"
    echo Deploy parent token to the native chain and connect to protocol
    echo "################################################################"
    echo
    forge script script/Deploy_TokenForProtocol.s.sol --ffi -vvv --non-interactive --rpc-url $NATIVE_CHAIN_RPC_URL --broadcast --gas-price 20

    if [ "$FOREIGN_DEPLOYMENT" = "y" ]; then 
        if [[ $os == *"Darwin"* ]]; then
            sed -i '' 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=FOREIGN/g' $ENV_FILE
        else
            sed -i 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=FOREIGN/g' $ENV_FILE 
        fi

        echo "################################################################"
        echo Deploy child token to the foreign chain and connect to protocol
        echo "################################################################"
        echo
        forge script script/Deploy_TokenForProtocol.s.sol --ffi -vvv --non-interactive --rpc-url $FOREIGN_CHAIN_RPC_URL --broadcast --gas-price 20

        if [[ $os == *"Darwin"* ]]; then
            sed -i '' 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=NATIVE/g' $ENV_FILE
        else
            sed -i 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=NATIVE/g' $ENV_FILE 
        fi
    fi

 else 
    echo "################################################################"
    echo Deploy parent token to the native chain
    echo "################################################################"
    echo $NATIVE_CHAIN_RPC_URL
    echo 
    echo
    forge script script/Deploy_Token.s.sol --ffi -vvv --non-interactive --rpc-url $NATIVE_CHAIN_RPC_URL --broadcast --gas-price 20

    if [ "$FOREIGN_DEPLOYMENT" = "y" ]; then 
        if [[ $os == *"Darwin"* ]]; then
            sed -i '' 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=FOREIGN/g' $ENV_FILE
        else
            sed -i 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=FOREIGN/g' $ENV_FILE 
        fi

        echo "################################################################"
        echo Deploy child token to the foreign chain
        echo "################################################################"
        echo
        forge script script/Deploy_Token.s.sol --ffi -vvv --non-interactive --rpc-url $FOREIGN_CHAIN_RPC_URL --broadcast --gas-price 20
    
        if [[ $os == *"Darwin"* ]]; then
            sed -i '' 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=NATIVE/g' $ENV_FILE
        else
            sed -i 's/CURRENT_DEPLOYMENT=.*/CURRENT_DEPLOYMENT=NATIVE/g' $ENV_FILE 
        fi
    fi
 fi
