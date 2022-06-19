// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MintNagaKids is AccessControl, ReentrancyGuard {

    IERC721Enumerable public nagaKidsContract;
    bool public isFreeMintOpen;
    bool public isWhitelistOpen;
    
    constructor(address _nagaKids) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        changeNagaKidsContract(_nagaKids);
    }

    function changeNagaKidsContract(IERC721Enumerable _nagaKids) onlyRole(DEFAULT_ADMIN_ROLE) {
        nagaKidsContract = _nagaKids
    }

    function changeWhitelistMintOpen(bool _isOpen) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isWhitelistOpen = _isOpen
    }

    function changeFreeMintOpen(bool _isOpen) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isFreeMintOpen = _isOpen
    }

    function whitelistMint() public payable nonReentrant {
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
