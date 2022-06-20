const { ethers } = require('ethers');
const { MerkleTree } = require('merkletreejs');

const WHITELIST_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["WHITELIST_MINT_ROUND"])
const NAGA_HOLDER_MINT_ROUND = ethers.utils.solidityKeccak256(["string"], ["NAGA_HOLDER_MINT_ROUND"])

console.log(WHITELIST_MINT_ROUND)

// The address in remix
let whitelistAddresses = [
  ["0x5B38DA6A701C568545DCFCB03FCB875F56BEDDC4", 1, WHITELIST_MINT_ROUND],
  ["0x5A641E5FB72A2FD9137312E7694D42996D689D99", 1, WHITELIST_MINT_ROUND],
  ["0xDCAB482177A592E424D1C8318A464FC922E8DE40", 2, WHITELIST_MINT_ROUND],
  ["0x6E21D37E07A6F7E53C7ACE372CEC63D4AE4B6BD0", 1, WHITELIST_MINT_ROUND],
  ["0x09BAAB19FC77C19898140DADD30C4685C597620B", 3, NAGA_HOLDER_MINT_ROUND],
  ["0xCC4C29997177253376528C05D3DF91CF2D69061A", 1, NAGA_HOLDER_MINT_ROUND],
  ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 1, NAGA_HOLDER_MINT_ROUND],
  ["0xb4c79dab8f259c7aee6e5b2aa729821864227e84", 3, NAGA_HOLDER_MINT_ROUND],
];

const leafNodes = whitelistAddresses.map(data => {
  let [address, amount, round] = data
  address = ethers.utils.getAddress(address)

  return ethers.utils.solidityKeccak256(["address", "uint256", "bytes32"], [address, amount, round]);
});

const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });

console.log('Whitelist Merkle Tree');
console.log(merkleTree.getRoot().toString());
console.log("Root Hash: ", merkleTree.getHexRoot());

const claimingAddress = leafNodes[7];

const hexProof = merkleTree.getHexProof(claimingAddress);
console.log("Proof: ", hexProof)

console.log(merkleTree.verify(hexProof, claimingAddress, merkleTree.getRoot()));
