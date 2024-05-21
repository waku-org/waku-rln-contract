// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IPoseidonHasher} from "rln-contract/PoseidonHasher.sol";
import {RlnBase, DuplicateIdCommitment, FullTree, InvalidIdCommitment} from "rln-contract/RlnBase.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

error NotImplemented();

error InvalidIdCommitmentIndex(uint256 idCommitment, uint256 index);

error MembershipStillActive(uint256 idCommitment);

contract WakuRln is Ownable, RlnBase {
    uint16 public immutable contractIndex;

    /// @notice The default TTL period in seconds for a membership
    uint40 public immutable MEMBERSHIP_TTL;

    /// @notice The expiry timestamp of a membership
    /// maps from idCommitment to a timestamp
    mapping(uint256 => uint40) public membershipExpiry;

    constructor(
        address _poseidonHasher,
        uint16 _contractIndex,
        uint40 _ttl
    ) Ownable() RlnBase(0, 20, _poseidonHasher, address(0)) {
        contractIndex = _contractIndex;
        MEMBERSHIP_TTL = _ttl;
    }

    function _setCommitment(uint256 idCommitment, uint256 index) internal {
        _validateRegistration(idCommitment);

        members[idCommitment] = index;
        memberExists[idCommitment] = true;
        membershipExpiry[idCommitment] = uint40(block.timestamp) + MEMBERSHIP_TTL;

        emit MemberRegistered(idCommitment, index);
    }

    /// Registers a member
    /// @param idCommitment The idCommitment of the member
    function _register(uint256 idCommitment) internal {
        if (idCommitmentIndex >= SET_SIZE) revert FullTree();

        _setCommitment(idCommitment, idCommitmentIndex);

        idCommitmentIndex += 1;
    }

    function register(uint256[] calldata idCommitments) external onlyOwner {
        uint256 len = idCommitments.length;
        for (uint256 i = 0; i < len; ) {
            _register(idCommitments[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// Register a member at specific index
    /// @param idCommitment The idCommitment of the member
    /// @param index The index in which to register the member
    function registerAtIndex(uint256 idCommitment, uint256 index) external onlyOwner {
        _validateIndexExpiration(idCommitment, index);
        _setCommitment(idCommitment, index);
    }

    /// Renew membership credentials
    function renew(uint256 idCommitment /*, uint256 periods*/) external onlyOwner {
        // TODO: should this function be payable, and also, accept renewals for more than 1 period?
        // if (msg.value != periods * MEMBERSHIP_DEPOSIT) revert InvalidTransactionValue()

        // TODO: should we allow renewals using a grace period?

        uint256 expiry = membershipExpiry[idCommitment];
        if (expiry == 0) revert InvalidIdCommitment(idCommitment);

        membershipExpiry[idCommitment] += MEMBERSHIP_TTL /* * periods */;
    }

    function register(uint256 idCommitment) external payable override {
        revert NotImplemented();
    }

    function slash(
        uint256 idCommitment,
        address payable receiver,
        uint256[8] calldata proof
    ) external pure override {
        revert NotImplemented();
    }

    function _validateRegistration(
        uint256 idCommitment
    ) internal view override {
        if (!isValidCommitment(idCommitment))
            revert InvalidIdCommitment(idCommitment);
        if (memberExists[idCommitment] == true) revert DuplicateIdCommitment();
    }

    function _validateIndexExpiration(
        uint256 idCommitment,
        uint256 index
    ) internal view {
        if (index >= SET_SIZE) revert InvalidIdCommitmentIndex(idCommitment, index);
        if (membershipExpiry[idCommitment] > block.timestamp) revert MembershipStillActive(idCommitment);
    }

    function _validateSlash(
        uint256 idCommitment,
        address payable receiver,
        uint256[8] calldata proof
    ) internal pure override {
        revert NotImplemented();
    }

    function withdraw() external pure override {
        revert NotImplemented();
    }
}
