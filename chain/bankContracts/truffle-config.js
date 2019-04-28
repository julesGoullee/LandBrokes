require('dotenv').config();
// const HDWalletProvider = require("truffle-hdwallet-provider");
// const mnemonic = process.env.MNEMONIC;
// const rpc = process.env.RPC;

module.exports = {

  networks: {

    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
      // gas: 6721975,
      // gasPrice: 20000000000,
      from: "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1",
    }

  },

  mocha: {
    enableTimeouts: false
  },

  compilers: {
    solc: {
      version: "0.5.7",
    },
  },

  solc: {
    optimizer: { // Turning on compiler optimization that removes some local variables during compilation
      enabled: true,
      runs: 200
    }
  }

};
