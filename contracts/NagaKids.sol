// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721ABurnable.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NagaKids is ERC721A, ERC721AQueryable, ERC721ABurnable, Ownable {

    using Strings for uint256;

    address public minter;

    string private baseURI;
    string public baseExtension = ".json";
    uint256 public constant maxSupply = 1111;

    event SetMinter(address indexed caller, address indexed minter);
    event SetBaseURI(string BaseURIBefore, string BaseURIAfter);

    modifier onlyMinter() {
        require(msg.sender == minter, "You are not a minter");
        _;
    }

    constructor(
        string memory _initBaseURI,
        address _preMintAddress
    ) ERC721A("NAGA KIDS", "NAGK") {

        // preMint 111 => ~ 10% of maxSuplly //
        safeMint(_preMintAddress,111);
    }

    function setMinter(address _minter) public onlyOwner {
        minter = _minter;
        emit SetMinter(msg.sender, minter);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        string memory _baseURIBefore = baseURI;
        baseURI = newBaseURI;

        emit SetBaseURI(baseURI,newBaseURI);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A,IERC721A) returns (string memory){
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) 
        : "";
    }
 
    function safeMint(address to,uint amount) public onlyMinter {
        require(totalSupply() + amount <= maxSupply, "Over max supply");
        _safeMint(to, amount);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721A,IERC721A)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

}