require('dotenv').config();

const Config = {
  tokenAddress: process.env.TOKEN_ADDRESS || '0x0000000000000000000000000000000000000000000000000000000000000000',
  privateKey: process.env.PRIVATE_KEY || '0x0123456789012345678901234567890123456789012345678901234567890123',
  infuraApiKey: process.env.INFURA_KEY || null,
  network: process.env.NETWORK || 'development',
  contractsAddress: {
    development: {
      addressContractBank: process.env.ADDRESS_BANK || '0x0',
      decentralandBidContract: process.env.DECENTRALAND_BID_CONTRACT || '0x0',
      decentralandMarketplaceContract: process.env.DECENTRALAND_MARLETPLACE_CONTRACT || '0x0',
      decentralandMarket: null,
      decentralandApi: null
    },
    ropsten: {
      addressContractBank: process.env.ADDRESS_BANK || '0x0',
      decentralandBidContract: process.env.DECENTRALAND_BID_CONTRACT || '0x0',
      decentralandMarketplaceContract: process.env.DECENTRALAND_MARLETPLACE_CONTRACT || '0x0',
      decentralandMarket: 'https://market.decentraland.zone',
      decentralandApi: 'https://api.decentraland.zone'
    }
  }
};

module.exports = Config;
