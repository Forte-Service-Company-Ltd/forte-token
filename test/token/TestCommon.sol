// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

///NOTE: Testing methodology for Protocol Token: 
/// ERC20 Upgradeable functions are tested locally and ensure proper functionallity 
/// AppManager and App Handler are needed for RBAC controls testing through token and upgrades 
/// Protocol integration will be tested with fork testing: Tests using testnet deployed Rule Processor 


import "test/token/TestUtils.sol";
import "src/token/ProtocolToken.sol";
import "src/token/ProtocolTokenProxy.sol";
import "test/token/EndWithStopPrank.sol"; 
import "tron/client/pricing/ProtocolERC721Pricing.sol";
import "tron/client/pricing/ProtocolERC20Pricing.sol";
import "tron/example/OracleApproved.sol";
import "tron/example/OracleDenied.sol";
import {AppManager} from "tron/client/application/AppManager.sol";
import {ProtocolApplicationHandler} from "tron/client/application/ProtocolApplicationHandler.sol";
import {DummyAMM} from "tronTest/client/token/TestTokenCommon.sol";


/**
 * @title Test Common 
 * @dev This abstract contract is to be used by other tests 
 */
abstract contract TestCommon is TestUtils, EndWithStopPrank {

    ProtocolToken public protocolToken; 
    ProtocolToken public protocolTokenUpgraded;
    ProtocolTokenProxy public protocolTokenProxy; 
    RuleProcessorDiamond public ruleProcessorDiamond; 
    AppManager public appManager;
    ProtocolApplicationHandler public appHandler; 
    DummyAssetHandler public assetHandlerTest; 
    OracleApproved public oracleApproved; 
    OracleDenied public oracleDenied; 
    DummyAMM public tokenAmm;
    ProtocolToken public testToken; 
    ProtocolTokenProxy public testTokenProxy; 
    ProtocolERC20Pricing public erc20Pricer;
    ProtocolERC721Pricing public erc721Pricer;

    bool public testDeployments;

    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address treasuryAccount = address(0xAAA);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address feeSink = address(0xDDF);
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address user4 = address(44);
    address user5 = address(55);
    address user6 = address(66);
    address user7 = address(77);
    address user8 = address(88);
    address user9 = address(99);
    address user10 = address(100);
    address proxyOwner = address(787);

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    uint256 constant ATTO = 10 ** 18;

    uint64 Blocktime = 7598888;
    modifier ifDeploymentTestsEnabled() {
        if (testDeployments) {
            _;
        }
    }

    function _deployERC20Upgradeable() public returns (ProtocolToken _protocolToken){
        return new ProtocolToken{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}();
    }

    function _deployERC20UpgradeableProxy(address _protocolToken, address _proxyOwner) public returns (ProtocolTokenProxy _tokenProxy){
        return new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(_protocolToken, _proxyOwner, "");
    }

    function _deployERC20UpgradeableNonDeterministic() public returns (ProtocolToken _protocolToken){
        return new ProtocolToken();
    }

    function _deployERC20UpgradeableProxyNonDeterministic(address _protocolToken, address _proxyOwner) public returns (ProtocolTokenProxy _tokenProxy){
        return new ProtocolTokenProxy(_protocolToken, _proxyOwner, "");
    }

    function _deployAppManagerAndHandler() public  returns (AppManager _appManager, ProtocolApplicationHandler _appHandler) {
        // This is needed for setting the permissions on the token intialize function 
        _appManager = new AppManager(superAdmin, "Wave", false);
        _appHandler = new ProtocolApplicationHandler(address(ruleProcessorDiamond), address(_appManager));
        return (_appManager, _appHandler);
    }

    function _deployAppManagerAndHandlerFork(address _ruleProcessorDiamond) public  returns (AppManager _appManager, ProtocolApplicationHandler _appHandler) {
        // This is needed for setting the permissions on the token intialize function 
        _appManager = new AppManager(superAdmin, "Wave", false);
        _appHandler = new ProtocolApplicationHandler(address(_ruleProcessorDiamond), address(_appManager));
        return (_appManager, _appHandler);
    }

    function _deployTokenHandler() public returns (HandlerDiamond _handlerDiamond){
        return _createERC20HandlerDiamond(); 
    }

    function setUpTokenWithHandler() public endWithStopPrank {
        vm.startPrank(superAdmin);
        // set a non zero address as rule processor for local testing
        ruleProcessorDiamond = _createRulesProcessorDiamond();
        // Deploy app manager and handler
        (appManager, appHandler) = _deployAppManagerAndHandler();
        // set app admin 
        appManager.addAppAdministrator(appAdministrator);
        // deploy token 
        protocolToken = _deployERC20Upgradeable(); 
        // deploy proxy 
        protocolTokenProxy = _deployERC20UpgradeableProxy(address(protocolToken), proxyOwner); 
        // deploy handler diamond 
        handlerDiamond = _deployTokenHandler();
        ERC20HandlerMainFacet(address(handlerDiamond)).initialize(address(ruleProcessorDiamond), address(appManager), address(protocolTokenProxy));
        // connect everything 
        switchToAppAdministrator(); 
        appManager.setNewApplicationHandlerAddress(address(appHandler));
        ProtocolToken(address(protocolTokenProxy)).initialize("Wave", "WAVE", address(appManager)); 
        ProtocolToken(address(protocolTokenProxy)).connectHandlerToToken(address(handlerDiamond)); 
        appManager.registerToken("WAVE", address(protocolTokenProxy));

        oracleApproved = new OracleApproved();
        oracleDenied = new OracleDenied();

        erc20Pricer = new ProtocolERC20Pricing();
        erc20Pricer.setSingleTokenPrice(address(protocolTokenProxy), 1 * (10 ** 18));
        erc721Pricer = new ProtocolERC721Pricing();
        switchToRuleAdmin();
        appHandler.setERC20PricingAddress(address(erc20Pricer)); 
        appHandler.setNFTPricingAddress(address(erc721Pricer)); 
        vm.warp(Blocktime);
    }
    

    // USER SWITCHING 

    function switchToAppAdministrator() public {
        vm.stopPrank();
        switchToSuperAdmin();
        appManager.addAppAdministrator(appAdministrator); //set a app administrator
        vm.stopPrank(); //stop interacting as the app admin
        vm.startPrank(appAdministrator); //interact as the created app administrator
    }

    function switchToAccessLevelAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addAccessLevelAdmin(accessLevelAdmin); //add AccessLevel admin
        vm.stopPrank(); //stop interacting as the access level admin
        vm.startPrank(accessLevelAdmin); //interact as the created AccessLevel admin
    }

    function switchToTreasuryAccount() public {
        switchToAppAdministrator();
        appManager.addTreasuryAccount(treasuryAccount);
        vm.stopPrank();
        vm.startPrank(treasuryAccount);
    }

    function switchToRiskAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addRiskAdmin(riskAdmin); //add Risk admin
        vm.stopPrank(); //stop interacting as the risk admin
        vm.startPrank(riskAdmin); //interact as the created Risk admin
    }

    function switchToRuleAdmin() public {
        switchToAppAdministrator(); // create a app administrator and make it the sender.
        appManager.addRuleAdministrator(ruleAdmin); //add Rule admin
        vm.stopPrank(); //stop interacting as the rule admin
        vm.startPrank(ruleAdmin); //interact as the created Rule admin
    }

    function switchToUser() public {
        vm.stopPrank(); //stop interacting as the previous admin
        vm.startPrank(user1); //interact as the user
    }

    function switchToUser2() public {
        vm.stopPrank(); //stop interacting as the previous admin
        vm.startPrank(user2); //interact as the user
    }

    function switchToUser3() public {
        vm.stopPrank(); //stop interacting as the previous admin
        vm.startPrank(user3); //interact as the user
    }

    /**
     * @dev Function to set the super admin as the calling address. It stores the current address for future resetting
     *
     */
    function switchToSuperAdmin() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
    }

    function _get4RandomAddresses(uint8 _addressIndex) internal view returns (address, address, address, address) {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        return (addressList[0], addressList[1], addressList[2], addressList[3]);
    }

    /**
     * @dev this function ensures that unique addresses can be randomly retrieved from the address array.
     */
    function getUniqueAddresses(uint256 _seed, uint8 _number) public view returns (address[] memory _addressList) {
        _addressList = new address[](ADDRESSES.length);
        // first one will simply be the seed
        _addressList[0] = ADDRESSES[_seed];
        uint256 j;
        if (_number > 1) {
            // loop until all unique addresses are returned
            for (uint256 i = 1; i < _number; i++) {
                // find the next unique address
                j = _seed;
                do {
                    j++;
                    // if end of list reached, start from the beginning
                    if (j == ADDRESSES.length) {
                        j = 0;
                    }
                    if (!exists(ADDRESSES[j], _addressList)) {
                        _addressList[i] = ADDRESSES[j];
                        break;
                    }
                } while (0 == 0);
            }
        }
        return _addressList;
    }

    // Check if an address exists in the list
    function exists(address _address, address[] memory _addressList) public pure returns (bool) {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (_address == _addressList[i]) {
                return true;
            }
        }
        return false;
    }
}