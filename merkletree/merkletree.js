const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");

const WHITELIST_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["WHITELIST_MINT_ROUND"]);
const NAGA_HOLDER_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["NAGA_HOLDER_MINT_ROUND"]);

// The address in remix
const whitelistAddresses = [
    ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", 2, WHITELIST_MINT_ROUND],
    ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", 3, NAGA_HOLDER_MINT_ROUND],
];

const leafNodes = whitelistAddresses.map((data) => {
    let [address, amount, round] = data;
    address = ethers.utils.getAddress(address);

    return ethers.utils.solidityKeccak256(["address", "uint256", "bytes32"], [address, amount, round]);
});

const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });

console.log("Whitelist Merkle Tree");
console.log(merkleTree.toString());
console.log("Root Hash FOR DEPLOY: ", merkleTree.getHexRoot());

const claimingAddress = leafNodes[0];

const hexProof = merkleTree.getHexProof(claimingAddress);
console.log("Proof: ", hexProof); // ["0xf30a102a6f437bec78958e5c3b65eb50b20800b7216a20070b13f9ae6c0c9a2d"]
console.log(merkleTree.verify(hexProof, claimingAddress, merkleTree.getRoot()));