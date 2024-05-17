// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

///NOTE: Testing methodology for Protocol Token: 
/// ERC20 Upgradeable functions are tested locally and ensure proper functionallity 
/// Protocol integration will be tested with fork testing: Tests using testnet deployed Rule Processor 
/// Rule Testing and Invariant testing is done in Tron repo using testnet deployed Token, token handler, app manager and app handler address 


import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import "test/token/EndWithStopPrank.sol"; 
// import "tron/client/application/AppManager.sol";
// import "tron/client/token/handler/diamond/HandlerDiamond.sol";
import "tron/protocol/economic/ruleProcessor/ruleProcessorDiamond.sol";
import "tron/client/pricing/ProtocolERC721Pricing.sol";
import "tron/client/pricing/ProtocolERC20Pricing.sol";
import "tron/example/OracleApproved.sol";
import "tron/example/OracleDenied.sol";



/**
 * @title Test Common 
 * @dev This abstract contract is to be used by other tests 
 */
abstract contract testCommon {

    ProtocolToken public protocolToken; 
    ProtocolTokenProxy public protocolTokenProxy; 


    bool public testDeployments = true;

    modifier ifDeploymentTestsEnabled() {
        if (testDeployments) {
            _;
        }
    }

    function _deployERC20Upgradeable() public returns (ProtocolToken _protocolToken){
        return new ProtocolToken();
    }

    function _deployERC20UpgradeableProxy(address _protocolToken, address _proxyOwner) public returns (ProtocolTokenProxy _tokenProxy){
        return new ProtocolTokenProxy(_protocolToken, _proxyOwner, "");
    }

    function _deployAppManagerAndHandler() public  {
        // This is needed for setting the permissions on the token intialize function 

    }

    function _deployTokenWithHandler() public {

    }

    function setUpTokenWithHandler() public {

    }
    

}