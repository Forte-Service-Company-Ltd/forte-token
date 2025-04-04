// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
// Diamond Imports 
import "rulesEngine/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {IDiamondCut} from "rulesEngineLib/diamond-std/core/DiamondCut/IDiamondCut.sol";
import {IDiamondInit} from "rulesEngineLib/diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "rulesEngineLib/diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "rulesEngineLib/diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {SampleFacet} from "rulesEngineLib/diamond-std/core/test/SampleFacet.sol";
import {SampleUpgradeFacet} from "rulesEngine/protocol/diamond/SampleUpgradeFacet.sol";
import "rulesEngine/protocol/diamond/ProtocolNativeFacet.sol";
import "rulesEngine/protocol/diamond/ProtocolRawFacet.sol";
import {ERC173Facet} from "rulesEngineLib/diamond-std/implementations/ERC173/ERC173Facet.sol";
import {HandlerVersionFacet} from "rulesEngine/client/token/handler/diamond/HandlerVersionFacet.sol";
import {VersionFacet} from "rulesEngine/protocol/diamond/VersionFacet.sol";
// Handler Diamond Imports 
import {HandlerDiamond, HandlerDiamondArgs} from "rulesEngine/client/token/handler/diamond/HandlerDiamond.sol";
import "rulesEngine/client/token/handler/diamond/IHandlerDiamond.sol";
import {FeesFacet} from "rulesEngine/client/token/handler/diamond/FeesFacet.sol";
import {ERC20HandlerMainFacet} from "rulesEngine/client/token/handler/diamond/ERC20HandlerMainFacet.sol";
import {ERC721HandlerMainFacet} from "rulesEngine/client/token/handler/diamond/ERC721HandlerMainFacet.sol";
import "rulesEngine/client/token/handler/diamond/ERC20TaggedRuleFacet.sol";
import "rulesEngine/client/token/handler/diamond/ERC20NonTaggedRuleFacet.sol";
import "rulesEngine/client/token/handler/diamond/ERC721TaggedRuleFacet.sol";
import "rulesEngine/client/token/handler/diamond/ERC721NonTaggedRuleFacet.sol";

import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules, IApplicationRules as AppRules} from "rulesEngine/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import {ERC20RuleProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import {ERC721TaggedRuleProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import {ERC721RuleProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol";
import {RuleApplicationValidationFacet} from "rulesEngine/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol";
import {ApplicationRiskProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import {ApplicationPauseProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol";
import {ApplicationAccessLevelProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import {ApplicationRiskProcessorFacet} from "rulesEngine/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import {TaggedRuleDataFacet} from "rulesEngine/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "rulesEngine/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "rulesEngine/protocol/economic/ruleProcessor/AppRuleDataFacet.sol";

import "rulesEngine/client/token/IProtocolTokenHandler.sol";
import "rulesEngineScripts/EnabledActionPerRuleArray.sol";

contract TestUtils is Test, EnabledActionPerRuleArray {

    HandlerDiamond public handlerDiamond;
    FacetCut[] _ruleProcessorFacetCuts;
    function _createERC20HandlerDiamond() public returns (HandlerDiamond diamond) {
        FacetCut[] memory _erc20HandlerFacetCuts = new FacetCut[](8);
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[8] memory facets = [
            // diamond version
            "HandlerVersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // // Raw implementation facets.
            "ProtocolRawFacet",
            // ERC20 Handler Facets
            "ERC20HandlerMainFacet",
            "ERC20TaggedRuleFacet",
            "ERC20NonTaggedRuleFacet",
            "TradingRuleFacet",
            "FeesFacet"
        ];

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Create the FacetCut struct for this facet.
            _erc20HandlerFacetCuts[facetIndex] = FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: _createSelectorArray(facet)});
        }

        // Build the DiamondArgs.
        HandlerDiamondArgs memory diamondArgs = HandlerDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Build the diamond
        HandlerDiamond handlerInternal = new HandlerDiamond(_erc20HandlerFacetCuts, diamondArgs);

        // Deploy the diamond.
        return handlerInternal;
    }

    /**
     * @dev Deploy and set up the Rules Processor Diamond
     * @return diamond fully configured rules processor diamond
     */
    function _createRulesProcessorDiamond() public returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();
        _addNativeFacetsToFacetCut();
        _addStorageFacetsToFacetCut();
        _addProcessingFacetsToFacetCut();

        // Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Build the diamond
        // Deploy the diamond.
        RuleProcessorDiamond ruleProcessorInternal = new RuleProcessorDiamond(_ruleProcessorFacetCuts, diamondArgs);
        /// setup enabled actions
        _setEnabledActionsPerRule(address(ruleProcessorInternal));
        return ruleProcessorInternal;
    }

    function _setEnabledActionsPerRule(address ruleProcessorAddress) internal {
        for (uint i; i < enabledActionPerRuleArray.length; ++i) {
            RuleApplicationValidationFacet(ruleProcessorAddress).enabledActionsInRule(enabledActionPerRuleArray[i].ruleName, enabledActionPerRuleArray[i].enabledActions);
        }
    }

    function _addNativeFacetsToFacetCut() public {
        // Protocol Facets
        ProtocolNativeFacet protocolNativeFacet = new ProtocolNativeFacet();
        ProtocolRawFacet protocolRawFacet = new ProtocolRawFacet();
        VersionFacet versionFacet = new VersionFacet();

        // Native
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(protocolNativeFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ProtocolNativeFacet")}));

        // Raw
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(protocolRawFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ProtocolRawFacet")}));

        // Version
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(versionFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("VersionFacet")}));
    }

    function _addProcessingFacetsToFacetCut() public {
        // Rule Processor Facets
        ERC20RuleProcessorFacet erc20RuleProcessorFacet = new ERC20RuleProcessorFacet();
        ERC721RuleProcessorFacet erc721RuleProcessorFacet = new ERC721RuleProcessorFacet();
        ApplicationRiskProcessorFacet applicationRiskProcessorFacet = new ApplicationRiskProcessorFacet();
        ApplicationAccessLevelProcessorFacet applicationAccessLevelProcessorFacet = new ApplicationAccessLevelProcessorFacet();
        ApplicationPauseProcessorFacet applicationPauseProcessorFacet = new ApplicationPauseProcessorFacet();
        RuleApplicationValidationFacet ruleApplicationValidationFacet = new RuleApplicationValidationFacet();
        ERC721TaggedRuleProcessorFacet erc721TaggedRuleProcessorFacet = new ERC721TaggedRuleProcessorFacet();
        ERC20TaggedRuleProcessorFacet erc20TaggedRuleProcessorFacet = new ERC20TaggedRuleProcessorFacet();

        // Standard
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(erc20RuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC20RuleProcessorFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(erc721RuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC721RuleProcessorFacet")}));

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationRiskProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationRiskProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationAccessLevelProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationAccessLevelProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(applicationPauseProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ApplicationPauseProcessorFacet")})
        );

        // Tagged
        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(erc20TaggedRuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC20TaggedRuleProcessorFacet")})
        );

        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(erc721TaggedRuleProcessorFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("ERC721TaggedRuleProcessorFacet")})
        );

        // Validation
        _ruleProcessorFacetCuts.push(
            FacetCut({facetAddress: address(ruleApplicationValidationFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("RuleApplicationValidationFacet")})
        );
    }

    function _addStorageFacetsToFacetCut() public {
        // Rule Processing Facets
        RuleDataFacet ruleDataFacet = new RuleDataFacet();
        TaggedRuleDataFacet taggedRuleDataFacet = new TaggedRuleDataFacet();
        AppRuleDataFacet appRuleDataFacet = new AppRuleDataFacet();

        // Standard
        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(ruleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("RuleDataFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(appRuleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("AppRuleDataFacet")}));

        _ruleProcessorFacetCuts.push(FacetCut({facetAddress: address(taggedRuleDataFacet), action: FacetCutAction.Add, functionSelectors: _createSelectorArray("TaggedRuleDataFacet")}));
    }

    function _createSelectorArray(string memory _facet) public returns (bytes4[] memory _selectors) {
        string[] memory _inputs = new string[](3);
        _inputs[0] = "python3";
        _inputs[1] = "lib/tron/script/python/get_selectors.py";
        _inputs[2] = _facet;
        bytes memory res = vm.ffi(_inputs);
        return abi.decode(res, (bytes4[]));
    }

}
// Note This is an unsafe contract implementation and should not be used to test the validity of the Protocol Rules or asset handler 
contract DummyAssetHandler is IProtocolTokenHandler {

    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, address _sender, uint256 value) external pure returns (bool) {
        balanceFrom;
        balanceTo;
        _from;
        _to;
        _sender;
        value;
        
        return true; 
    }

}
