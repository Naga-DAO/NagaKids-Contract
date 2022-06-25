// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/IERC721A.sol";
import "erc721a/contracts/extensions/IERC721ABurnable.sol";
import "erc721a/contracts/extensions/IERC721AQueryable.sol";


interface INagaKid is IERC721A,IERC721AQueryable {

    function maxSupply() external view returns (uint256);
    function safeMint(address to,uint amount) external;
    
}