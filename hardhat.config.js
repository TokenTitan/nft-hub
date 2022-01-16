require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");
require("hardhat-deploy");
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  solidity: "0.8.0",
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_ALCHEMY_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
      throwOnTransactionFailures: true,
      loggingEnabled: true,
    },
    arbitrum: {
      url: process.env.ARBITRUM_ALCHEMY_URL,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
