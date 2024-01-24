// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {RlnBase, DuplicateIdCommitment, FullTree, InvalidIdCommitment} from "rln-contract/RlnBase.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

error NotImplemented();
error MalformedCommitmentToMessageLimitMap();

function isValidCommitmentToMessageLimitMap(uint256[] calldata commitments, uint256[] calldata limits)
    pure
    returns (bool)
{
    uint256 commitmentsLen = commitments.length;
    uint256 limitsLen = limits.length;
    if (commitmentsLen != limitsLen) return false;
    return true;
}

contract WakuRln is Ownable, RlnBase {
    uint16 public immutable contractIndex;

    constructor(uint256 _maxMessageLimit, uint16 _contractIndex)
        Ownable()
        RlnBase(0, 20, _maxMessageLimit, address(0))
    {
        contractIndex = _contractIndex;
    }

    modifier onlyValidCommitmentToMessageLimitMap(uint256[] calldata commitments, uint256[] calldata limits) {
        if (!isValidCommitmentToMessageLimitMap(commitments, limits)) {
            revert MalformedCommitmentToMessageLimitMap();
        }
        _;
    }

    /// Registers a member
    /// @param idCommitment The idCommitment of the member
    /// @param userMessageLimit The userMessageLimit of the member
    function _register(uint256 idCommitment, uint256 userMessageLimit) internal {
        _validateRegistration(idCommitment, userMessageLimit);

        members[idCommitment] = idCommitmentIndex;
        indexToCommitment[idCommitmentIndex] = idCommitment;
        memberExists[idCommitment] = true;
        userMessageLimits[idCommitment] = userMessageLimit;

        emit MemberRegistered(idCommitment, userMessageLimit, idCommitmentIndex);
        idCommitmentIndex += 1;
    }

    function register(uint256[] calldata commitments, uint256[] calldata limits)
        external
        onlyOwner
        onlyValidCommitmentToMessageLimitMap(commitments, limits)
    {
        uint256 len = commitments.length;
        for (uint256 i = 0; i < len;) {
            _register(commitments[i], limits[i]);
            unchecked {
                ++i;
            }
        }
    }

    function register(uint256 idCommitment, uint256 userMessageLimit) external payable override {
        _register(idCommitment, userMessageLimit);
    }

    function slash(uint256 idCommitment, address payable receiver, uint256[8] calldata proof) external pure override {
        revert NotImplemented();
    }

    function _validateRegistration(uint256 idCommitment, uint256 userMessageLimit)
        internal
        view
        override
        onlyValidUserMessageLimit(userMessageLimit)
        onlyValidIdCommitment(idCommitment)
    {
        if (memberExists[idCommitment] == true) revert DuplicateIdCommitment();
        if (idCommitmentIndex >= SET_SIZE) revert FullTree();
    }

    function _validateSlash(uint256 idCommitment, address payable receiver, uint256[8] calldata proof)
        internal
        pure
        override
    {
        revert NotImplemented();
    }

    function withdraw() external pure override {
        revert NotImplemented();
    }
}
