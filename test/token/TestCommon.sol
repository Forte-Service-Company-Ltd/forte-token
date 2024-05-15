// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

///NOTE: Testing methodology for Protocol Token: 
/// ERC20 Upgradeable functions are tested locally and ensure proper functionallity 
/// Protocol integration will be tested with fork testing: Tests using testnet deployed Rule Processor 
/// Rule Testing and Invariant testing is done in Tron repo using testnet deployed Token, token handler, app manager and app handler address 



import "forge-std/Test.sol";
import "test/token/EndWithStopPrank.sol"; 
import "tron/src/protocol/economic/IRuleProcessor.sol";
// import "tron/src/client/application/AppManager.sol";
//import "tron/src/client/token/handler/diamond/IHandlerDiamond.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";


/**
 * @title Test Common 
 * @dev This abstract contract is to be used by other tests 
 */
abstract contract testCommon {

    IRuleProcessor public ruleProcessor;
    ProtocolToken public protocolToken; 
    ProtocolTokenProxy public protocolTokenProxy; 
    // AppManager public appManager; 


    bool public testDeployments = true;

    modifier ifDeploymentTestsEnabled() {
        if (testDeployments) {
            _;
        }
    }

    function deployRuleProcessorDiamond() public {

    }

    function _deployERC20Upgradeable() public returns (ProtocolToken _token){
        
    }

    function _deployERC20UpgradeableProxy() public returns (ProtocolToken _tokenProxy){
        
    }

    // function _deployAppManagerAndHandler() public returns (AppManager _appManager) {
    //     appManager = new AppManager(msg.sender, "ProtocolApp", false); 
    //     return (appManager); 
    // }

    function setUpTokenWithHandler() public {

    }
    

}