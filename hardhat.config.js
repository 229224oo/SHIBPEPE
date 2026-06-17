import "@nomiclabs/hardhat-waffle";

export default {
  solidity: "0.8.0",
  networks: {
    testnet: {
      url: "https://bsc-testnet.publicnode.com",
      chainId: 97,
      accounts: ["0x7c0c634b9f01c1b1d787346d58acc00333d3abf4d0ae3134f978d8ce2eb68de2"]
    },
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: ["0x7c0c634b9f01c1b1d787346d58acc00333d3abf4d0ae3134f978d8ce2eb68de2"]
    }
  }
};