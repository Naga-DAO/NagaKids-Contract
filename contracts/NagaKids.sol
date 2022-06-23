// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NagaKids is ERC721, ERC721Enumerable, Ownable, ERC721Burnable {

    using Counters for Counters.Counter;
    using Strings for *;

    mapping(address => bool) private _allowMinter;

    Counters.Counter private _tokenIdCounter;

    string private baseURI;
    string public baseExtension = ".json";
    uint256 public constant maxSupply = 1111;

    event SetAllowMinter(address indexed caller, address indexed minter, bool allowed);

    modifier Minter(address _minter) {
        require(isMinter(_minter),"You are not a minter");
        _;
    }

    constructor(
        string memory _initBaseURI,
        address _preMintAddress
    ) ERC721("NAGA KIDS", "NAGK") {

        setBaseURI(_initBaseURI);

        // set Owner is minter //
        setAllowMinter(msg.sender,true);

        // preMint 111 => ~ 10% of maxSuplly //
        batchMint(_preMintAddress,111);
    }

    function setAllowMinter(address minter, bool allowed) public onlyOwner {
        _allowMinter[minter] = allowed;
        emit SetAllowMinter(msg.sender, minter, allowed);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) 
        : "";
    }

    function batchMint(address to,uint amount) public Minter(msg.sender) {
        uint256 tokenId = _tokenIdCounter.current(); 
        require(tokenId + amount < maxSupply, "Over max supply");
        for(uint i = 0; i < amount; i++){
            _tokenIdCounter.increment();
            _safeMint(to, _tokenIdCounter.current());
        }
    }
 
    function safeMint(address to) public Minter(msg.sender) {
        uint256 tokenId = _tokenIdCounter.current(); 
        require(tokenId < maxSupply, "Over max supply");
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());
    }

    function isMinter(address minter) public view returns(bool) {
        return _allowMinter[minter];
    }

    function walletOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
        address currentTokenOwner = ownerOf(currentTokenId);

        if (currentTokenOwner == owner) {
            ownedTokenIds[ownedTokenIndex] = currentTokenId;

            ownedTokenIndex++;
        }

        currentTokenId++;
        }

        return ownedTokenIds;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
