// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MintNagaKids is ReentrancyGuard {

    IERC721Enumerable public nagaKidsContract;
    
    constructor(address _nagaKids) {
        changeNagaKidsContract(_nagaKids);
    }

    function changeNagaKidsContract(IERC721Enumerable _nagaKids) {
        nagaKidsContract = _nagaKids
    }

    function whitelistMint() public nonReentrant {
        require(
            getTotalSupply() < 1111,
            "Over supply"
        )

        

    }

    function setNagaKidsAddress(address _address) public {
        nagaKidsContract = _address;
    }

    function getTotalSupply() public view returns (uint256) {
        return nagaKidsContract.totalSupply();
    }

    function getMaxSupply() public view returns (uint256) {
        return nagaKidsContract.maxSupply();
    }
}
