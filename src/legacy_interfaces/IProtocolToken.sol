// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {IIntegrationEvents} from "src/legacy_interfaces/IEvents.sol";

/**
 * @title  Protocol Token Interface implementation model
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4
 * @notice This is the base contract for all protocol tokens
 * @dev Using this interface requires the implementing token properly handle the listed functions as well as insert the checkAllRules hook into _beforeTokenTransfer
 */
interface IProtocolToken is IIntegrationEvents{

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address);

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external;
}
