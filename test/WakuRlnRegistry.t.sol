// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/WakuRlnRegistry.sol";
import {MalformedCommitmentToMessageLimitMap} from "../contracts/WakuRln.sol";
import {DuplicateIdCommitment, FullTree, InvalidUserMessageLimit} from "rln-contract/RlnBase.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {noDuplicate, noInvalidCommitment, isValidCommitment, noInvalidMessageLimit} from "./utils.sol";
import "forge-std/Test.sol";
import "forge-std/StdCheats.sol";

contract WakuRlnRegistryTest is Test {
    using stdStorage for StdStorage;

    WakuRlnRegistry public wakuRlnRegistry;

    uint256 private constant MAX_MESSAGE_LIMIT = 20;

    function setUp() public {
        address implementation = address(new WakuRlnRegistry());
        bytes memory data = abi.encodeCall(WakuRlnRegistry.initialize, ());
        address proxy = address(new ERC1967Proxy(implementation, data));
        wakuRlnRegistry = WakuRlnRegistry(proxy);
    }

    function test__NewStorage() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
    }

    function test__RegisterStorage_BadIndex() public {
        wakuRlnRegistry.registerStorage(address(new WakuRln(MAX_MESSAGE_LIMIT, 0)));
        address newStorage = address(new WakuRln(MAX_MESSAGE_LIMIT, 0));
        vm.expectRevert(IncompatibleStorageIndex.selector);
        wakuRlnRegistry.registerStorage(newStorage);
    }

    function test__ValidRegistration(uint256[] calldata commitments) public {
        vm.assume(noInvalidCommitment(commitments));
        vm.assume(noDuplicate(commitments));
        uint256[] memory limits = new uint256[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            limits[i] = 1;
        }
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        wakuRlnRegistry.register(commitments, limits);
    }

    function test__InvalidRegistration__MalformedMap() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        uint256[] memory commitments = new uint256[](2);
        commitments[0] = 1;
        commitments[1] = 2;
        uint256[] memory limits = new uint256[](1);
        limits[0] = 1;
        vm.expectRevert(MalformedCommitmentToMessageLimitMap.selector);
        wakuRlnRegistry.register(commitments, limits);
    }

    function test__InvalidRegistration__Duplicate(uint256[] calldata commitments) public {
        vm.assume(noInvalidCommitment(commitments));
        vm.assume(!noDuplicate(commitments));

        uint256[] memory limits = new uint256[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            limits[i] = 1;
        }

        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        vm.expectRevert(DuplicateIdCommitment.selector);
        wakuRlnRegistry.register(commitments, limits);
    }

    function test__InvalidRegistration__InvalidUserMessageLimit() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        uint256[] memory commitments = new uint256[](1);
        commitments[0] = 1;
        uint256[] memory limits = new uint256[](1);
        limits[0] = 21;
        vm.expectRevert(abi.encodeWithSelector(InvalidUserMessageLimit.selector, 21));
        wakuRlnRegistry.register(commitments, limits);
    }

    function test__forceProgression() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        wakuRlnRegistry.forceProgress();
        assertEq(wakuRlnRegistry.usingStorageIndex(), 1);
        assertEq(wakuRlnRegistry.nextStorageIndex(), 2);
    }

    function test__SingleRegistration(uint256 commitment) public {
        vm.assume(isValidCommitment(commitment));
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        wakuRlnRegistry.register(0, commitment, MAX_MESSAGE_LIMIT);
    }

    function test__InvalidSingleRegistration__NoStorageContract(uint256 commitment) public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        vm.assume(isValidCommitment(commitment));
        vm.expectRevert(NoStorageContractAvailable.selector);
        wakuRlnRegistry.register(1, commitment, MAX_MESSAGE_LIMIT);
    }

    function test__InvalidSingleRegistration__Duplicate(uint256 commitment) public {
        vm.assume(isValidCommitment(commitment));
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        wakuRlnRegistry.register(0, commitment, MAX_MESSAGE_LIMIT);
        vm.expectRevert(DuplicateIdCommitment.selector);
        wakuRlnRegistry.register(0, commitment, MAX_MESSAGE_LIMIT);
    }

    function test__InvalidSingleRegistration__FullTree() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        WakuRln wakuRln = WakuRln(wakuRlnRegistry.storages(0));
        uint256 commitment = 1;

        vm.mockCallRevert(
            address(wakuRln),
            abi.encodeWithSignature("register(uint256,uint256)", commitment, MAX_MESSAGE_LIMIT),
            abi.encodeWithSelector(FullTree.selector)
        );
        vm.expectRevert(FullTree.selector);
        wakuRlnRegistry.register(0, commitment, MAX_MESSAGE_LIMIT);
    }

    function test__InvalidRegistration__NoStorageContract() public {
        wakuRlnRegistry.newStorage(MAX_MESSAGE_LIMIT);
        WakuRln wakuRln = WakuRln(wakuRlnRegistry.storages(0));

        uint256[] memory commitments = new uint256[](1);
        commitments[0] = 1;
        uint256[] memory limits = new uint256[](1);
        limits[0] = 1;

        vm.mockCallRevert(
            address(wakuRln),
            abi.encodeWithSignature("register(uint256[],uint256[])", commitments, limits),
            abi.encodeWithSelector(FullTree.selector)
        );
        vm.expectRevert(NoStorageContractAvailable.selector);
        wakuRlnRegistry.register(commitments, limits);
    }

    function test__forceProgression__NoStorageContract() public {
        vm.expectRevert(NoStorageContractAvailable.selector);
        wakuRlnRegistry.forceProgress();
        assertEq(wakuRlnRegistry.usingStorageIndex(), 0);
        assertEq(wakuRlnRegistry.nextStorageIndex(), 0);
    }
}
