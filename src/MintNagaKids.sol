// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MintNagaKids is ReentrancyGuard {

    IERC721Enumerable public nagaKidsContract;
    bool public isFreeMintOpen;
    bool public isWhitelistOpen;
    
    constructor(address _nagaKids) {
        changeNagaKidsContract(_nagaKids);
    }

    function changeNagaKidsContract(IERC721Enumerable _nagaKids) {
        nagaKidsContract = _nagaKids
    }

    function changeWhitelistMintOpen(bool _isOpen) public {
        isWhitelistOpen = _isOpen
    }

    function changeFreeMintOpen(bool _isOpen) public {
        isFreeMintOpen = _isOpen
    }

    function whitelistMint() public nonReentrant {
        require(isWhitelistOpen == true,"Whitelist not open to mint.");
        require(
            getTotalSupply() < 1111,
            "Over supply"
        )

    }

    function getTotalSupply() public view returns (uint256) {
        return nagaKidsContract.totalSupply();
    }

    function getMaxSupply() public view returns (uint256) {
        return nagaKidsContract.maxSupply();
    }
}
