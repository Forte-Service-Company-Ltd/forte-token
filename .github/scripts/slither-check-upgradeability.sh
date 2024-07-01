#!/bin/bash
export TERM=xterm-color
BLUE="\e[94m"
ENDBLUE="\e[0m"
# Helper script for running the slither-check-upgradeability tool

# ****** ERC20 Upgradeable Contract ******
erc20uContracts=(ProtocolToken)

for c in "${erc20uContracts[@]}"; do
  printf "${BLUE}***** Contract: $c Proxy: ProtocolTokenProxy *****${ENDBLUE}\n"
  slither-check-upgradeability . "$c" --proxy-name ProtocolTokenProxy
done