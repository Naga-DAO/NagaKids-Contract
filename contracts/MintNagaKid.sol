// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./INagaKid.sol";

contract MintNagaKid is AccessControl, ReentrancyGuard {

    bytes32 public constant WHITELIST_MINT_ROUND = 0x68e7d51fdb912cb107dda2e59b053d87fcca666dd0ef5339cd3474ccb5276bba; // keccak256("WHITELIST_MINT_ROUND");
    bytes32 public constant NAGA_HOLDER_MINT_ROUND = 0xb3c595e55271590809f54e2f4fc3a582754f45b104dd3c41666e2ad310493db3; // keccak256("NAGA_HOLDER_MINT_ROUND");
    bytes32 public constant DEFAULT = 0x0000000000000000000000000000000000000000000000000000000000000000;
    
    INagaKid public nagaKidContract;
    bytes32 public currentMintRound;
    bytes32 public merkleRoot;

    mapping(address => mapping(bytes32 => bool)) internal _isUserMinted;
    mapping(address => mapping(bytes32 => uint256)) internal _userMintedAmount;

    // Events
    event Minted(address indexed user, uint256 amount, uint256 timestamp);
    event NagaKidContractChanged(address nagaKidBefore, address nagaKidAfter);
    event MerkleRootChanged(bytes32 merkleRootBefore, bytes32 merkleRootAfter);
    event RoundChanged(bytes32 roundBefore, bytes32 roundAfter);

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
        address nagaKidBefore = address(nagaKidContract);
        nagaKidContract = _nagaKid;
        address nagaKidAfter = address(_nagaKid);

        emit NagaKidContractChanged(nagaKidBefore, nagaKidAfter);
    }

    function setRound(bytes32 _round) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 _roundBefore = currentMintRound;
        currentMintRound = _round;

        emit RoundChanged(_roundBefore, _round);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 _merkleRootBefore = merkleRoot;
        merkleRoot = _merkleRoot;

        emit MerkleRootChanged(_merkleRootBefore, _merkleRoot);
    }

    function mint(bytes32[] calldata _proof, uint256 _amount, bytes32 _round) public payable nonReentrant Paused {
        require(_round != DEFAULT,"Mint is not approved.");
        require(currentMintRound == _round, "You are not in this minting round.");
        require(getTotalSupply() + _amount < getMaxSupply(), "Over supply");
        require(isUserMinted(msg.sender,_round) == false, "You are already minted.");
        require(nagaKidContract.hasRole(nagaKidContract.MINTER_ROLE(), address(this)) == true, "Contract Mint is not approved.");
        require(MerkleProof.verify(_proof, merkleRoot, keccak256(abi.encodePacked(msg.sender, _amount, _round))), "Unauthorized WhitelistMint This User.");

        _isUserMinted[msg.sender][_round] = true;
        _userMintedAmount[msg.sender][_round] += _amount;

        nagaKidContract.batchMint(msg.sender,_amount);

        emit Minted(msg.sender, _amount, block.timestamp);
    }

    function isUserMinted(address _user,bytes32 _round) public view returns(bool) {
        return _isUserMinted[_user][_round];
    }

    function userMintedAmount(address _user,bytes32 _round) public view returns(uint256) {
        return _userMintedAmount[_user][_round];
    }

    function getTotalSupply() public view returns (uint256) {
        return nagaKidContract.totalSupply();
    }

    function getMaxSupply() public view returns (uint256) {
        return nagaKidContract.maxSupply();
    }

    function isPause() public view returns (bool) {
        return nagaKidContract.paused();
    }
}
