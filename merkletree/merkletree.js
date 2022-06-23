const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

const WHITELIST_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["WHITELIST_MINT_ROUND"]);
const NAGA_HOLDER_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["NAGA_HOLDER_MINT_ROUND"]);

console.log(WHITELIST_MINT_ROUND);

// The address in remix
let whitelistAddresses = [
    ["0x6d644A42aCc9156437f20Ac002F1a73A74863Efa", 2, WHITELIST_MINT_ROUND],
    ["0x6d644A42aCc9156437f20Ac002F1a73A74863Efa", 3, NAGA_HOLDER_MINT_ROUND],
];

const leafNodes = whitelistAddresses.map((data) => {
    let [address, amount, round] = data;
    address = ethers.utils.getAddress(address);

    return ethers.utils.solidityKeccak256(["address", "uint256", "bytes32"], [address, amount, round]);
});

const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });

console.log("Whitelist Merkle Tree");
console.log(merkleTree.getRoot().toString());
console.log("Root Hash: ", merkleTree.getHexRoot());

const claimingAddress = leafNodes[0];

const hexProof = merkleTree.getHexProof(claimingAddress);
console.log("Proof: ", hexProof);
console.log(merkleTree.verify(hexProof, claimingAddress, merkleTree.getRoot()));
