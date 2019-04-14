var HDWalletProvider = require("truffle-hdwallet-provider");

require('dotenv').config()

var mnemonic = process.env.MNEMONIC
var rpc = process.env.RPC

module.exports = {

  networks: {

    development: {
      host: "ganache",
      port: 8545,
      network_id: "*",
      from: "0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1",
      gas: 7000000,
      gasPrice: 20000000000
    }

  },

  mocha: {
    enableTimeouts: false
  },

  compilers: {
    solc: {
      version: "0.5.2",
    },
  },

  solc: {
    optimizer: { // Turning on compiler optimization that removes some local variables during compilation
      enabled: true,
      runs: 200
    }
  }

};
