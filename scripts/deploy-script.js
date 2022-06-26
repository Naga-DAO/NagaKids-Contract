// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

function delay(ms: number) {
  return new Promise( resolve => setTimeout(resolve, ms) );
}


async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const hre = require("hardhat");
  const NagaKids = await ethers.getContractFactory("NagaKids");
  const kids = await NagaKids.deploy("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/", 0x0E71D23d8ed622EE422bfcDa6E064433C34C4329);

  await kids.deployed();
  console.log("NagaKids deployed to:", kids.address);

  await delay(60000);

  const SaleKids = await ethers.getContractFactory("SaleKids");
  const sale = await SaleKids.deploy("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/", 0x0E71D23d8ed622EE422bfcDa6E064433C34C4329);

  await hre.run("verify:verify", {
    address: kids.address,
    constructorArguments: ["ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/", 0x0E71D23d8ed622EE422bfcDa6E064433C34C4329],
  }); 

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
