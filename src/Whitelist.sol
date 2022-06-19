// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Whitelist {

    bytes32 public merkleRoot;

    function isWhitelist(
        bytes32[] calldata _proof,
        address _user,
        uint256 _amount
    ) internal view returns (bool) {
        if (merkleRoot == 0) {
            return false;
        }

        return
            MerkleProof.verify(
                _proof,
                merkleRoot,
                keccak256(abi.encodePacked(_user, _amount))
            );
            
    }

}
