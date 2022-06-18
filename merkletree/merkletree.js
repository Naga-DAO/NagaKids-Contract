const { ethers } = require('ethers');
const { MerkleTree } = require('merkletreejs');

// The address in remix
let whitelistAddresses = [
  ["0x5B38DA6A701C568545DCFCB03FCB875F56BEDDC4", 1],
  ["0x5A641E5FB72A2FD9137312E7694D42996D689D99", 1],
  ["0xDCAB482177A592E424D1C8318A464FC922E8DE40", 2],
  ["0x6E21D37E07A6F7E53C7ACE372CEC63D4AE4B6BD0", 1],
  ["0x09BAAB19FC77C19898140DADD30C4685C597620B", 3],
  ["0xCC4C29997177253376528C05D3DF91CF2D69061A", 1],
  ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 1],
];

const leafNodes = whitelistAddresses.map(data => {
  let [address, amount] = data

  address = ethers.utils.getAddress(address)

  const leafData = ethers.utils.defaultAbiCoder.encode(
    ["address", "uint256"],
    [address, amount]
  );

  return ethers.utils.keccak256(leafData);
});

const merkleTree = new MerkleTree(leafNodes, ethers.utils.keccak256, { sortPairs: true });

const rootHash = merkleTree.getRoot();
console.log('Whitelist Merkle Tree');
console.log(merkleTree.toString());
console.log("Root Hash: ", rootHash.toString('hex'));

const claimingAddress = leafNodes[6];

const hexProof = merkleTree.getHexProof(claimingAddress);
console.log(merkleTree.verify(hexProof, claimingAddress, rootHash));
