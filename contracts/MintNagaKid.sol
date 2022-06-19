// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./VerifySignature.sol";
import "./Whitelist.sol";
import "./INagaKid.sol";

contract MintNagaKid is Whitelist, VerifySignature, AccessControl, ReentrancyGuard {

    INagaKid public NagaKidContract;

    bool public isPublicMintOpen;
    bool public isWhitelistMintOpen;

    address public signer;

    mapping(address => bool) internal _isWhitelistMinted;
    mapping(address => uint256) internal _isWhitelistMintedAmount;
    mapping(address => bool) internal _isPublicMinted;

    event WhitelistMinted(address indexed user,uint256 amount,uint256 timestamp);
    event PublicMinted(address indexed user,uint256 timestamp);
    event SetNagaKidContract(address NagaKidBefore,address NagaKidAfter);
    event SetSigner(address signerBefore, address signerAfter);
    event SetWhitelistMintOpen(bool isOpen);
    event SetPublicMintOpen(bool isOpen);
    event SetMerkleRoot(bytes32 merkleRootBefore, bytes32 merkleRootAfter);

    constructor(INagaKid _nagaKidContract, bytes32 _merkleRoot) {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        setNagaKidContract(_nagaKidContract);
        setMerkleRoot(_merkleRoot);

    }

    modifier Paused() {
        require(isPause() == false,"NagaKid was Paused.");
        _;
    }

    function setNagaKidContract(INagaKid _nagaKid) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address NagaKidBefore = address(NagaKidContract);
        NagaKidContract = _nagaKid;
        address NagaKidAfter = address(_nagaKid);

        emit SetNagaKidContract(NagaKidBefore, NagaKidAfter);
    }
    
    function setSigner(address _signer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address signerBefore = signer;
        signer = _signer;

        emit SetSigner(signerBefore,_signer);
    } 

    function setWhitelistMintOpen(bool _isOpen) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isWhitelistMintOpen = _isOpen;

        emit SetWhitelistMintOpen(_isOpen);
    }

    function setPublicMintOpen(bool _isOpen) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isPublicMintOpen = _isOpen;

        emit SetPublicMintOpen(_isOpen);
    }
    
    function setMerkleRoot(bytes32 _merkleRoot) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 _merkleRootBefore = merkleRoot;
        merkleRoot = _merkleRoot;

        emit SetMerkleRoot(_merkleRootBefore,_merkleRoot);
    }

    function whitelistMint(bytes32[] calldata _proofMerkle, uint256 _amount) public payable nonReentrant Paused {
        require(isWhitelistMintOpen == true, "Whitelist not open to mint.");
        require(getTotalSupply() + _amount < 1111, "Over supply");
        require(isWhitelistMinted(msg.sender) != true, "You are already minted.");
        require(NagaKidContract.hasRole(NagaKidContract.MINTER_ROLE(),address(this)) == true,"This Contract not have permission to mint.");
        require(isWhitelist(_proofMerkle , msg.sender , _amount ), "Unauthorized WhitelistMint This User.");

        _isWhitelistMinted[msg.sender] = true;
        _isWhitelistMintedAmount[msg.sender] += _amount;

        for(uint i = 0; i< _amount; i++) {
            NagaKidContract.safeMint(msg.sender);
        }

        emit WhitelistMinted(msg.sender,_amount,block.timestamp);
    }

    function publicMint(bytes calldata _sig) public payable nonReentrant Paused {
        require(isPublicMintOpen == true, "Whitelist not open to mint.");
        require(tx.origin == msg.sender, "haha Contract can't call me");
        require(isPublicMinted(msg.sender) != true, "You are already minted.");
        require(getTotalSupply() + 1 < 1111,"Over Supply Amount");
        require(NagaKidContract.hasRole(NagaKidContract.MINTER_ROLE(),address(this)) == true,"This Contract not have permission to mint.");
        require(verify(signer,msg.sender,_sig), "Unauthorized PublicMint This User.");

        _isPublicMinted[msg.sender] = true;
        NagaKidContract.safeMint(msg.sender);
        
        emit PublicMinted(msg.sender,block.timestamp);
    }

    function isWhitelistMinted(address _user) public view returns(bool) {
        return _isWhitelistMinted[_user];
    }

    function isWhitelistMintedAmount(address _user) public view returns(uint256) {
        return _isWhitelistMintedAmount[_user];
    }

    function isPublicMinted(address _user) public view returns(bool) {
        return _isPublicMinted[_user];
    }

    function getTotalSupply() public view returns (uint256) {
        return NagaKidContract.totalSupply();
    }

    function getMaxSupply() public view returns (uint256) {
        return NagaKidContract.maxSupply();
    }

    function isPause() public view returns (bool) {
        return NagaKidContract.paused();
    }
}
