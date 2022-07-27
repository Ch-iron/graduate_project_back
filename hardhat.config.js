require("dotenv").config()
require("@nomiclabs/hardhat-ethers")

// const { API_URL, PRIVATE_KEY } = process.env

module.exports = {
  solidity: "0.8.7",
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/XIXnmQeANuo6sfzYKeBrlV92wm5cSysW",
      accounts: ["ec0ee2f3df88a096903a112e6c77e6ae35f54fc24132729d74e15200553ca872"],
    },
  },
}

