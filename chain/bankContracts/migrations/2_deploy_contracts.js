const Bank = artifacts.require('Bank');
// const { AbiCoder } = require('web3-eth-abi');
// const abiCoder = new AbiCoder();

require('dotenv').config();

const manaTicker = 'MANA';
const maxLandOwners = 30;
const maxLandSplits = 10000;
const maxBidDuration = 60 * 60 * 24 * 180; //180 days
const noActionCancelAfter = 60 * 60 * 24 * 60; //60 days

const addressManaToken = '0xCfEB869F69431e42cdB54A4F4f105C19C080A601';
const addressMarketplace = '0x9e90054F4B6730cffAf1E6f6ea10e1bF9dD26dbb';
const addressLandToken = '0xA57B8a5584442B467b4689F1144D269d096A3daF';
const addressLandProxy = '0xA57B8a5584442B467b4689F1144D269d096A3daF';
const addressDecentralandBid = '0x0000000000000000000000000000000000000000';

module.exports = async function (deployer, network, accounts) {

  if(network === 'development'){

    const params = [
      manaTicker,
      maxLandOwners,
      maxLandSplits,
      maxBidDuration,
      noActionCancelAfter,
      addressManaToken,
      addressMarketplace,
      addressLandToken,
      addressLandProxy,
      addressDecentralandBid,
    ];

    await deployer.deploy(Bank, ...params, { from: accounts[0] });

  } else if (network === 'ropsten') {}

  console.log(`
    Bank: ${Bank.address}
  `);
};
