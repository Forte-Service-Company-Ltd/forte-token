// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/token/TestCommon.sol";

/**
 * @title Test Arrays
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests.
 * This contract holds the functions for setting up arrays for each type. Functions create various sized array for each type.
 */

abstract contract TestArrays {
    /****************** UINT256 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint256 array to be used in tests 
    * @notice This function creates a uint256 array size of 1 
    * @return array uint256[] 
    */
    function createUint256Array(uint256 arg1) public pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint256 array to be used in tests
     * @notice This function creates a uint256 array size of 2
     * @return array uint256[]
     */
    function createUint256Array(uint256 arg1, uint256 arg2) public pure returns (uint256[] memory array) {
        array = new uint256[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint256 array to be used in tests
     * @notice This function creates a uint256 array size of 3
     * @return array uint256[]
     */
    function createUint256Array(uint256 arg1, uint256 arg2, uint256 arg3) public pure returns (uint256[] memory array) {
        array = new uint256[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /****************** UINT192 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint192 array to be used in tests 
    * @notice This function creates a uint192 array size of 1 
    * @return array uint192[] 
    */
    function createUint192Array(uint192 arg1) public pure returns (uint192[] memory array) {
        array = new uint192[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint192 array to be used in tests
     * @notice This function creates a uint192 array size of 2
     * @return array uint192[]
     */
    function createUint192Array(uint192 arg1, uint192 arg2) public pure returns (uint192[] memory array) {
        array = new uint192[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint192 array to be used in tests
     * @notice This function creates a uint192 array size of 3
     * @return array uint192[]
     */
    function createUint192Array(uint192 arg1, uint192 arg2, uint192 arg3) public pure returns (uint192[] memory array) {
        array = new uint192[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /****************** UINT240 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint240 array to be used in tests 
    * @notice This function creates a uint240 array size of 1 
    * @return array uint240[] 
    */
    function createUint240Array(uint240 arg1) public pure returns (uint240[] memory array) {
        array = new uint240[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint240 array to be used in tests
     * @notice This function creates a uint240 array size of 2
     * @return array uint240[]
     */
    function createUint240Array(uint240 arg1, uint240 arg2) public pure returns (uint240[] memory array) {
        array = new uint240[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint240 array to be used in tests
     * @notice This function creates a uint240 array size of 3
     * @return array uint240[]
     */
    function createUint240Array(uint240 arg1, uint240 arg2, uint240 arg3) public pure returns (uint240[] memory array) {
        array = new uint240[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /****************** UINT64 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint64 array to be used in tests 
    * @notice This function creates a uint64array size of 1 
    * @return array uint64[] 
    */
    function createUint64Array(uint64 arg1) public pure returns (uint64[] memory array) {
        array = new uint64[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint64 array to be used in tests
     * @notice This function creates a uint64 array size of 2
     * @return array uint64[]
     */
    function createUint64Array(uint64 arg1, uint64 arg2) public pure returns (uint64[] memory array) {
        array = new uint64[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint64 array to be used in tests
     * @notice This function creates a uint64 array size of 3
     * @return array uint64[]
     */
    function createUint64Array(uint64 arg1, uint64 arg2, uint64 arg3) public pure returns (uint64[] memory array) {
        array = new uint64[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a uint64 array to be used in tests
     * @notice This function creates a uint64 array size of 4
     * @return array uint64[]
     */
    function createUint64Array(uint64 arg1, uint64 arg2, uint64 arg3, uint64 arg4) public pure returns (uint64[] memory array) {
        array = new uint64[](4);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a uint64 array to be used in tests
     * @notice This function creates a uint64 array size of 5
     * @return array uint64[]
     */
    function createUint64Array(uint64 arg1, uint64 arg2, uint64 arg3, uint64 arg4, uint64 arg5) public pure returns (uint64[] memory array) {
        array = new uint64[](5);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
        array[4] = arg5;
    }

    /****************** UINT48 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint48 array to be used in tests 
    * @notice This function creates a uint48 array size of 1 
    * @return array uint48[] 
    */
    function createUint48Array(uint48 arg1) public pure returns (uint48[] memory array) {
        array = new uint48[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a u1648 array to be used in tests
     * @notice This function creates a uint48 array size of 2
     * @return array uint48[]
     */
    function createUint48Array(uint48 arg1, uint48 arg2) public pure returns (uint48[] memory array) {
        array = new uint48[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint48 array to be used in tests
     * @notice This function creates a uint48 array size of 3
     * @return array uint48[]
     */
    function createUint48Array(uint48 arg1, uint48 arg2, uint48 arg3) public pure returns (uint48[] memory array) {
        array = new uint48[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a uint48 array to be used in tests
     * @notice This function creates a uint48 array size of 4
     * @return array uint48[]
     */
    function createUint48Array(uint48 arg1, uint48 arg2, uint48 arg3, uint48 arg4) public pure returns (uint48[] memory array) {
        array = new uint48[](4);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a uint48 array to be used in tests
     * @notice This function creates a uint48 array size of 5
     * @return array uint48[]
     */
    function createUint48Array(uint48 arg1, uint48 arg2, uint48 arg3, uint48 arg4, uint48 arg5) public pure returns (uint48[] memory array) {
        array = new uint48[](5);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
        array[4] = arg5;
    }

    /****************** UINT16 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint16 array to be used in tests 
    * @notice This function creates a uint16 array size of 1 
    * @return array uint16[] 
    */
    function createUint16Array(uint16 arg1) public pure returns (uint16[] memory array) {
        array = new uint16[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint16 array to be used in tests
     * @notice This function creates a uint16 array size of 2
     * @return array uint16[]
     */
    function createUint16Array(uint16 arg1, uint16 arg2) public pure returns (uint16[] memory array) {
        array = new uint16[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint16 array to be used in tests
     * @notice This function creates a uint16 array size of 3
     * @return array uint16[]
     */
    function createUint16Array(uint16 arg1, uint16 arg2, uint16 arg3) public pure returns (uint16[] memory array) {
        array = new uint16[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /****************** UINT8 ARRAY CREATION ******************
    /**
    * @dev This function creates a uint8 array to be used in tests 
    * @notice This function creates a uint8 array size of 1 
    * @return array uint8[] 
    */
    function createUint8Array(uint8 arg1) public pure returns (uint8[] memory array) {
        array = new uint8[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint8 array to be used in tests
     * @notice This function creates a uint8 array size of 2
     * @return array uint8[]
     */
    function createUint8Array(uint8 arg1, uint8 arg2) public pure returns (uint8[] memory array) {
        array = new uint8[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint8 array to be used in tests
     * @notice This function creates a uint8 array size of 3
     * @return array uint8[]
     */
    function createUint8Array(uint8 arg1, uint8 arg2, uint8 arg3) public pure returns (uint8[] memory array) {
        array = new uint8[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a uint8 array to be used in tests
     * @notice This function creates a uint8 array size of 4
     * @return array uint8[]
     */
    function createUint8Array(uint8 arg1, uint8 arg2, uint8 arg3, uint8 arg4) public pure returns (uint8[] memory array) {
        array = new uint8[](4);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a uint8 array to be used in tests
     * @notice This function creates a uint8 array size of 5
     * @return array uint8[]
     */
    function createUint8Array(uint8 arg1, uint8 arg2, uint8 arg3, uint8 arg4, uint8 arg5) public pure returns (uint8[] memory array) {
        array = new uint8[](5);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
        array[4] = arg5;
    }

    /****************** BYTES32 ARRAY CREATION ******************
    /**
    * @dev This function creates a bytes32 array to be used in tests 
    * @notice This function creates a bytes32 array size of 1 
    * @return array bytes32[] 
    */
    function createBytes32Array(bytes32 arg1) public pure returns (bytes32[] memory array) {
        array = new bytes32[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a bytes32 array to be used in tests
     * @notice This function creates a bytes32 array size of 2
     * @return array bytes32[]
     */
    function createBytes32Array(bytes32 arg1, bytes32 arg2) public pure returns (bytes32[] memory array) {
        array = new bytes32[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a bytes32 array to be used in tests
     * @notice This function creates a bytes32 array size of 3
     * @return array bytes32[]
     */
    function createBytes32Array(bytes32 arg1, bytes32 arg2, bytes32 arg3) public pure returns (bytes32[] memory array) {
        array = new bytes32[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a bytes32 array to be used in tests
     * @notice This function creates a bytes32 array size of 3
     * @return array bytes32[]
     */
    function createBytes32Array(bytes32 arg1, bytes32 arg2, bytes32 arg3, bytes32 arg4) public pure returns (bytes32[] memory array) {
        array = new bytes32[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a bytes32 array to be used in tests
     * @notice This function creates a bytes32 array size of 8
     * @return array bytes32[]
     */
    function createBytes32Array(bytes32 arg1, bytes32 arg2, bytes32 arg3, bytes32 arg4, bytes32 arg5, bytes32 arg6, bytes32 arg7, bytes32 arg8) public pure returns (bytes32[] memory array) {
        array = new bytes32[](8);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
        array[4] = arg5;
        array[5] = arg6;
        array[6] = arg7;
        array[7] = arg8;
    }

    /****************** ADDRESS ARRAY CREATION ******************
    /**
    * @dev This function creates a address array to be used in tests 
    * @notice This function creates a address array size of 1
    * @return array address[] 
    */
    function createAddressArray(address arg1) public pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a address array to be used in tests
     * @notice This function creates a address array size of 2
     * @return array address[]
     */
    function createAddressArray(address arg1, address arg2) public pure returns (address[] memory array) {
        array = new address[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a address array to be used in tests
     * @notice This function creates a address array size of 3
     * @return array address[]
     */
    function createAddressArray(address arg1, address arg2, address arg3) public pure returns (address[] memory array) {
        array = new address[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a address array to be used in tests
     * @notice This function creates a address array size of 3
     * @return array address[]
     */
    function createAddressArray(address arg1, address arg2, address arg3, address arg4) public pure returns (address[] memory array) {
        array = new address[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 1
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](1);
        array[0] = arg1;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 2
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1, ActionTypes arg2) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](2);
        array[0] = arg1;
        array[1] = arg2;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 3
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1, ActionTypes arg2, ActionTypes arg3) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](3);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 4
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1, ActionTypes arg2, ActionTypes arg3, ActionTypes arg4) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](4);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 5
     * @return array uint8[]
     */
    function createActionTypeArray(ActionTypes arg1, ActionTypes arg2, ActionTypes arg3, ActionTypes arg4, ActionTypes arg5) public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](5);
        array[0] = arg1;
        array[1] = arg2;
        array[2] = arg3;
        array[3] = arg4;
        array[4] = arg5;
    }

    /**
     * @dev This function creates a uint8 array for Action Types to be used in tests
     * @notice This function creates a uint8 array size of 5
     * @return array uint8[]
     */
    function createActionTypeArrayAll() public pure returns (ActionTypes[] memory array) {
        array = new ActionTypes[](5);
        array[0] = ActionTypes.P2P_TRANSFER;
        array[1] = ActionTypes.BURN;
        array[2] = ActionTypes.MINT;
        array[3] = ActionTypes.SELL;
        array[4] = ActionTypes.BUY;
    }
}
