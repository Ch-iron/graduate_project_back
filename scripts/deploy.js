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

  // const CUTokenSwap = await hre.ethers.getContractFactory("CUTokenSwap");
  // const cutokenswap = await CUTokenSwap.deploy(cutoken.address);
  // console.log("Contract deployed to address", cutokenswap.address);

  // const UserParticipationList = await hre.ethers.getContractFactory("UserParticipationList");
  // const userparticipationlist = await UserParticipationList.deploy();
  // console.log("Contract deployed to address", userparticipationlist.address);

  // const Union = await hre.ethers.getContractFactory("Union");
  // const union = await UnionFactory.deploy();
  // console.log("Contract deployed to address", unionfactory.address);

  // const UnionFactory = await hre.ethers.getContractFactory("UnionFactory");
  // const unionfactory = await UnionFactory.deploy();
  // console.log("Contract deployed to address", unionfactory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
