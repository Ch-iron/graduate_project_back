// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const CUToken = await hre.ethers.getContractFactory("CUToken");
  const cutoken = await CUToken.deploy();

  console.log("Contract deployed to address", cutoken.address);

  const CUTokenSwap = await hre.ethers.getContractFactory("CUTokenSwap");
  const cutokenswap = await CUTokenSwap.deploy('0xDE2b20180827BF70D70e712E72519Bc7609Bddef', '0x62EE3A6521a1Cf48679dFeef07a9978b9131cb12', 10**4);

  console.log("Contract deployed to address", cutokenswap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
