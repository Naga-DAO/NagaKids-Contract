// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable {
    bytes32 public merkleRoot;

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhitelist(
        bytes32[] calldata _proof,
        address _address,
        uint256 _amount
    ) external view returns (bool) {
        if (merkleRoot == 0) {
            return false;
        }

        return
            MerkleProof.verify(
                _proof,
                merkleRoot,
                keccak256(abi.encodePacked(_address, _amount))
            );
    }
}
