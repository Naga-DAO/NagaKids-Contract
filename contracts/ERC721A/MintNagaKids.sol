// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./INagaKid.sol";
import "./VerifySignature.sol";

contract MintNagaKids is Ownable, ReentrancyGuard, VerifySignature {

    bytes32 public constant WHITELIST_MINT_ROUND = keccak256("WHITELIST_MINT_ROUND"); // 0x68e7d51fdb912cb107dda2e59b053d87fcca666dd0ef5339cd3474ccb5276bba
    bytes32 public constant NAGA_HOLDER_MINT_ROUND = keccak256("NAGA_HOLDER_MINT_ROUND"); // 0xb3c595e55271590809f54e2f4fc3a582754f45b104dd3c41666e2ad310493db3
  
    bytes32 public constant DEFAULT = 0x0000000000000000000000000000000000000000000000000000000000000000;
    
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    INagaKid public nagaKidContract;
    bytes32 public currentMintRound;
    bytes32 public merkleRoot;

    bool public isPublicMintOpen = false;
    bool public isPrivateMintOpen = false;

    address public signer;

    mapping(address => mapping(bytes32 => bool)) internal _isUserMinted;
    mapping(address => mapping(bytes32 => uint256)) internal _userMintedAmount;
    mapping(address => bool) internal _isPublicMinted;

    // Events
    event PrivateMinted(address indexed user, uint256 amount, uint256 timestamp);
    event PublicMinted(address indexed user, uint256 amount, uint256 timestamp);
    event NagaKidContractChanged(address nagaKidBefore, address nagaKidAfter);
    event MerkleRootChanged(bytes32 merkleRootBefore, bytes32 merkleRootAfter);
    event RoundChanged(bytes32 roundBefore, bytes32 roundAfter);
    event SignerChanged(address signerBefore,address signerAfter);
    event Withdraw(address to, uint256 balanceOFContract , uint256 timestamp);
    event WithdrawCurrency(address to,address currency,uint256 balanceOfContract,uint256 timestamp);
    event WithdrawNFT(address to,address NFT,uint256 tokenId, uint256 timestamp);
    event PublicMintChanged(bool boolean);
    event PrivateMintChanged(bool boolean);

    constructor(INagaKid _nagaKidContract,address _signer, bytes32 _merkleRoot) {
        
        setNagaKidContract(_nagaKidContract);
        setMerkleRoot(_merkleRoot);
        setSigner(_signer);

    }

    function setPublicMint(bool _bool) public onlyOwner {
        isPublicMintOpen = _bool;

        emit PublicMintChanged(_bool);
    }

    function setPrivateMint(bool _bool) public onlyOwner {
        isPrivateMintOpen = _bool;

        emit PrivateMintChanged(_bool);
    }

    function setNagaKidContract(INagaKid _nagaKid) public onlyOwner {
        address nagaKidBefore = address(nagaKidContract);
        nagaKidContract = _nagaKid;
        address nagaKidAfter = address(_nagaKid);

        emit NagaKidContractChanged(nagaKidBefore, nagaKidAfter);
    }

    function setRound(bytes32 _round) public onlyOwner {
        bytes32 _roundBefore = currentMintRound;
        currentMintRound = _round;

        emit RoundChanged(_roundBefore, _round);
    }

    function setSigner(address _signer) public onlyOwner {
        address _signerBefore = signer;
        signer = _signer;

        emit SignerChanged(_signerBefore, _signer);
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        bytes32 _merkleRootBefore = merkleRoot;
        merkleRoot = _merkleRoot;

        emit MerkleRootChanged(_merkleRootBefore, _merkleRoot);
    }

    function allowlistMint(bytes32[] calldata _proof, uint256 _amount, bytes32 _round) public payable nonReentrant {
        require(isPrivateMintOpen == true,"Private mint is not open.");
        require(_round != DEFAULT,"Mint is not approved.");
        require(currentMintRound == _round, "Contract are not in this minting round.");
        require(getTotalSupply() + _amount < getMaxSupply(), "Over supply");
        require(isUserMinted(msg.sender,_round) == false, "You are already minted.");
        require(nagaKidContract.isMinter(address(this)), "Contract Mint is not approved.");
        require(MerkleProof.verify(_proof, merkleRoot, keccak256(abi.encodePacked(msg.sender, _amount, _round))), "Unauthorized WhitelistMint This User.");

        _isUserMinted[msg.sender][_round] = true;
        _userMintedAmount[msg.sender][_round] += _amount;

        nagaKidContract.safeMint(msg.sender,_amount);

        emit PrivateMinted(msg.sender, _amount, block.timestamp);
    }

    function publicMint(bytes calldata _sig) public payable nonReentrant {

        require(isPublicMintOpen == true, "Public mint is not open.");
        require(tx.origin == msg.sender, "haha Contract can't call me");
        require(isPublicMinted(msg.sender) != true, "You are already minted.");
        // require(getTotalSupply() + 1 < 1111,"Over Supply Amount");
        require(nagaKidContract.isMinter(address(this)), "Contract Mint is not approved.");
        require(verify(signer,msg.sender,_sig), "Unauthorized PublicMint This User.");

        // publicMint User can get only 1 //
        uint256 _amount = 1; 

        _isPublicMinted[msg.sender] = true;
        nagaKidContract.safeMint(msg.sender,_amount);
        
        emit PublicMinted(msg.sender,_amount,block.timestamp);

    }

    function isPublicMinted(address _addr) public view returns(bool){
        return _isPublicMinted[_addr];
    }

    function withdraw(address _to) public onlyOwner {
        uint balanceOFContract = address(this).balance;
        require(balanceOFContract > 0, "Insufficient Balance");
        (bool status,) = _to.call{value: balanceOFContract }("");
        require(status);

        emit Withdraw(_to, balanceOFContract ,block.timestamp);
    }

    function withdrawCurrency(address _to,address _currency) public onlyOwner {
        uint balanceOfContract = IERC20(_currency).balanceOf(address(this));
        require(balanceOfContract > 0, "Insufficient Balance");
        IERC20(_currency).transfer(_to, balanceOfContract);
        
        emit WithdrawCurrency(_to,_currency,balanceOfContract,block.timestamp);
    }

    function withdrawNFT(address _to,address _NFT,uint256 _tokenId) public onlyOwner {
        require(IERC721(_NFT).ownerOf(_tokenId) == address(this), "This tokenId is not owned by contract");

        IERC721(_NFT).safeTransferFrom(address(this), _to, _tokenId);
        
        emit WithdrawNFT(_to,_NFT,_tokenId,block.timestamp);
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

}
