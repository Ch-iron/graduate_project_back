require("dotenv").config({path: './process.env'})
require("@nomiclabs/hardhat-ethers")

// const { API_URL, PRIVATE_KEY } = process.env

module.exports = {
  solidity: "0.8.7",
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: process.env.API_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
}

