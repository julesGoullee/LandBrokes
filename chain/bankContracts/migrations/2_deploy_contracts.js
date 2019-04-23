const Bank = artifacts.require('Bank');
// const { AbiCoder } = require('web3-eth-abi');
// const abiCoder = new AbiCoder();

require('dotenv').config();

const manaTicker = 'MANA';
const maxLandOwners = 30;
const maxLandSplits = 10000;
const maxBidDuration = 60 * 60 * 24 * 180; //180 days
const noActionCancelAfter = 60 * 60 * 24 * 60; //60 days

const addressDecentralandBid = '0x5581364f1350B82Ed4E25874f3727395BF6Ce490';
const addressLandToken= '0x26b4AFb60d6C903165150C6F0AA14F8016bE4aec';
const addressLandRegistry= '0x26b4AFb60d6C903165150C6F0AA14F8016bE4aec';
const addressManaToken = '0x5b1869D9A4C187F2EAa108f3062412ecf0526b24';

module.exports = async function (deployer, network, accounts) {

  if(network === 'development'){

    const params = [
      manaTicker,
      maxLandOwners,
      maxLandSplits,
      maxBidDuration,
      noActionCancelAfter,
      addressManaToken,
      addressDecentralandBid,
      addressLandToken,
      addressLandRegistry
    ];

    await deployer.deploy(Bank, ...params, { from: accounts[0] });

  } else if (network === 'ropsten') {}

  console.log(`
    Bank: ${Bank.address}
  `);
};
