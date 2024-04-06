// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

function noDuplicate(uint256[] calldata comms) pure returns (bool) {
    uint256 len = comms.length;
    for (uint256 i = 0; i < len; i++) {
        for (uint256 j = i + 1; j < len; j++) {
            if (comms[i] == comms[j]) {
                return false;
            }
        }
    }
    return true;
}

function noInvalidCommitment(uint256[] calldata comms) pure returns (bool) {
    uint256 len = comms.length;
    for (uint256 i = 0; i < len; i++) {
        if (!isValidCommitment(comms[i])) {
            return false;
        }
    }
    return true;
}

function noInvalidMessageLimit(uint256[] calldata limits, uint256 limit) pure returns (bool) {
    uint256 len = limits.length;
    for (uint256 i = 0; i < len; i++) {
        if (limits[i] > limit || limits[i] == 0) {
            return false;
        }
    }
    return true;
}

function isValidCommitment(uint256 id) pure returns (bool) {
    return id < 21_888_242_871_839_275_222_246_405_745_257_275_088_548_364_400_416_034_343_698_204_186_575_808_495_617
        && id != 0;
}
