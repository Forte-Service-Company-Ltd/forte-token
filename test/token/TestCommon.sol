// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

///NOTE: Testing methodology for Protocol Token: 
/// ERC20 Upgradeable functions are tested locally and ensure proper functionallity 
/// Protocol integration will be tested with fork testing: Tests using testnet deployed Rule Processor 


import "src/token/ProtocolTokenv2.sol";
import "src/token/ProtocolTokenProxy.sol";
import "test/token/EndWithStopPrank.sol"; 
import {DummyAMM} from "test/token/TestTokenCommon.sol";
import "forte-rules-engine/utils/DiamondMine.sol";

/**
 * @title Test Common 
 * @dev This abstract contract is to be used by other tests 
 */
abstract contract TestCommon is DiamondMine, EndWithStopPrank {

    ProtocolTokenv2 public protocolToken; 
    ProtocolTokenv2 public protocolTokenUpgraded;
    ProtocolTokenProxy public protocolTokenProxy; 
    // OracleApproved public oracleApproved; 
    // OracleDenied public oracleDenied; 
    DummyAMM public tokenAmm;
    ProtocolTokenv2 public testToken; 
    ProtocolTokenProxy public testTokenProxy; 

    bool public testDeployments;

    // common addresses
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
    address minterAdmin = address(800);
    address proxyAdmin = address(600);
    address RED_OWNER = address(500);
    address PROXY_OWNER = address(600);
    address TOKEN_ADMIN = address(700);
    address MINTER_ADMIN = address(800);
    address USER_1 = address(100);
    address policyAdmin;
    address tokenAdmin = address(700);
    address callingContractAdmin;

    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    uint256 constant ATTO = 10 ** 18;

    bytes32 public constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint64 Blocktime = 7598888;
    modifier ifDeploymentTestsEnabled() {
        if (testDeployments) {
            _;
        }
    }

    function _deployERC20UpgradeableV2() public returns (ProtocolTokenv2 _protocolToken){
        return new ProtocolTokenv2{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}();
    }

    function _deployERC20Upgradeable() public returns (ProtocolTokenv2 _protocolToken){
        return new ProtocolTokenv2{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}();
    }

    function _deployERC20UpgradeableProxy(address _protocolToken, address _proxyAdmin) public returns (ProtocolTokenProxy _tokenProxy){
        return new ProtocolTokenProxy{salt: keccak256(abi.encode(vm.envString("SALT_STRING")))}(_protocolToken, _proxyAdmin, "");
    }

    function _deployERC20UpgradeableNonDeterministic() public returns (ProtocolTokenv2 _protocolToken){
        return new ProtocolTokenv2();
    }

    function _deployERC20UpgradeableProxyNonDeterministic(address _protocolToken, address _proxyAdmin) public returns (ProtocolTokenProxy _tokenProxy){
        return new ProtocolTokenProxy(_protocolToken, _proxyAdmin, "");
    }


    function setUpTokenWithEngine() public endWithStopPrank {
        policyAdmin = MINTER_ADMIN;
        callingContractAdmin = TOKEN_ADMIN;
        vm.startPrank(tokenAdmin);
        red = createRulesEngineDiamond(RED_OWNER);
        // deploy token 
        protocolToken = _deployERC20UpgradeableV2(); 
        // deploy proxy 
        protocolTokenProxy = _deployERC20UpgradeableProxy(address(protocolToken), PROXY_OWNER); 
        // Connect proxy to token
        ProtocolTokenv2(address(protocolTokenProxy)).initialize("Token", "TOK", TOKEN_ADMIN); 
        vm.startPrank(TOKEN_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).grantRole(MINTER_ROLE, MINTER_ADMIN);
        // Connect token to Fore Rules Engine
        vm.startPrank(TOKEN_ADMIN);
        ProtocolTokenv2(address(protocolTokenProxy)).connectHandlerToToken(address(red));
        ProtocolTokenv2(address(protocolTokenProxy)).setCallingContractAdmin(callingContractAdmin);
    }
    

    // USER SWITCHING 
    function switchToProxyAdmin() public {
        vm.stopPrank(); //stop interacting as the app admin
        vm.startPrank(proxyAdmin); //interact as the created app administrator
    }
    function switchToMinterAdmin() public {
        vm.stopPrank(); //stop interacting as the app admin
        vm.startPrank(minterAdmin); //interact as the created app administrator
    }

    function switchToTokenAdmin() public {
        vm.stopPrank(); //stop interacting as the token admin
        vm.startPrank(tokenAdmin); //interact as the created app administrator
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
