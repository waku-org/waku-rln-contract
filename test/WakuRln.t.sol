// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./utils.sol";
import "../contracts/WakuRln.sol";
import "forge-std/Test.sol";
import "forge-std/StdCheats.sol";

contract WakuRlnTest is Test {
    using stdStorage for StdStorage;

    WakuRln public wakuRln;

    uint256 public constant MEMBERSHIP_DEPOSIT = 1000000000000000;
    uint256 public constant DEPTH = 20;
    uint256 public constant SET_SIZE = 1048576;
    uint256 public constant MAX_MESSAGE_LIMIT = 20;

    uint256[8] public zeroedProof = [0, 0, 0, 0, 0, 0, 0, 0];

    /// @dev Setup the testing environment.
    function setUp() public {
        wakuRln = new WakuRln(20, 0);
    }

    /// @dev Ensure that you can hash a value.
    function test__Constants() public {
        assertEq(wakuRln.DEPTH(), DEPTH);
        assertEq(wakuRln.SET_SIZE(), SET_SIZE);
        assertEq(wakuRln.deployedBlockNumber(), block.number);
        assertEq(wakuRln.MAX_MESSAGE_LIMIT(), MAX_MESSAGE_LIMIT);
    }

    function test__ValidRegistration() public {
        // Register a batch of commitments
        uint256[] memory commitments = new uint256[](10);
        uint256[] memory limits = new uint256[](10);

        for (uint256 i = 0; i < commitments.length; i++) {
            commitments[i] = i + 1;
            limits[i] = 1;
        }

        wakuRln.register(commitments, limits);
    }

    function test__InvalidRegistration__Duplicate() public {
        // Register a batch of commitments
        uint256[] memory commitments = new uint256[](2);
        commitments[0] = 1;
        commitments[1] = 1;
        vm.expectRevert(DuplicateIdCommitment.selector);
        wakuRln.register(commitments, commitments);
    }

    function test__InvalidRegistration__MalformedMap() public {
        // Register a batch of commitments
        uint256[] memory commitments = new uint256[](2);
        commitments[0] = 1;
        commitments[1] = 2;
        uint256[] memory limits = new uint256[](1);
        limits[0] = 1;
        vm.expectRevert(MalformedCommitmentToMessageLimitMap.selector);
        wakuRln.register(commitments, limits);
    }

    function test__InvalidFeatures() public {
        uint256 idCommitment = 1;
        vm.expectRevert(NotImplemented.selector);
        wakuRln.slash(idCommitment, payable(address(0)), zeroedProof);
        vm.expectRevert(NotImplemented.selector);
        wakuRln.withdraw();
    }
}
