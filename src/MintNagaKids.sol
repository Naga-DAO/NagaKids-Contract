// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface INagaKids {
    function totalSupply() external view returns (uint256);

    function maxSupply() external view returns (uint256);
}

contract MintNagaKids is ReentrancyGuard {
    address public nagaKidsContract;
    uint256 totalSupply;
    uint256 maxSupply;

    function whitelistMint() public nonReentrant {
        require(nagaKidsContract != address(0x0));
        require(
            INagaKids(nagaKidsContract).totalSupply() < 1111,
            "Over supply"
        );
        totalSupply = INagaKids(nagaKidsContract).totalSupply();
        maxSupply = INagaKids(nagaKidsContract).maxSupply();
    }

    function setNagaKidsAddress(address _address) public {
        nagaKidsContract = _address;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getMaxSupply() public view returns (uint256) {
        return maxSupply;
    }
}
