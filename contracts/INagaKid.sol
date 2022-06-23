// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INagaKid is IERC721 {

    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function isMinter(address minter) external view returns(bool);
    function batchMint(address _to,uint _amount) external;
    function safeMint(address _to) external;
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    
}
