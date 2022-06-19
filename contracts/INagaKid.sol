// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

interface INagaKid is IERC721,IAccessControl {

    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function paused() external view returns (bool);
    function safeMint(address to) external;
    function PAUSER_ROLE() external view returns (bytes32);
    function MINTER_ROLE() external view returns (bytes32);

}
