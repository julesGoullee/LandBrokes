const MANAToken = artifacts.require('MANAToken');
const Bank = artifacts.require('Bank');
// const { AbiCoder } = require('web3-eth-abi');
// const abiCoder = new AbiCoder();

require('dotenv').config();

const defaultMANAAmount = '10000000000000000000';
const manaTicker = 'MANA';
const maxLandOwners = 30;
const maxLandSplits = 10000;
const maxBidDuration = 60 * 60 * 24 * 180; //180 days
const noActionCancelAfter = 60 * 60 * 24 * 60; //60 days

const addressDecentralandBid = '0x5581364f1350B82Ed4E25874f3727395BF6Ce490';
const addressLandToken= '0x5581364f1350B82Ed4E25874f3727395BF6Ce490';
const addressLandRegistry= '0x254dffcd3277C0b1660F6d42EFbB754edaBAbC2B';

module.exports = async function (deployer, network, accounts) {

  if(network === 'development'){

    //Deploying savings branch

    await deployer.deploy(MANAToken, { from: accounts[0] });

    const mana = await MANAToken.deployed();

    //Give MANA to each address

    for(let i = 0; i < accounts.length; i++){

      await mana.mint(accounts[0], defaultMANAAmount, { from: accounts[0] });

    }

    const params = [
      manaTicker,
      maxLandOwners,
      maxLandSplits,
      maxBidDuration,
      noActionCancelAfter,
      mana.address,
      addressDecentralandBid,
      addressLandToken,
      addressLandRegistry
    ];

    await deployer.deploy(Bank, ...params, { from: accounts[0] });

  } else if (network === 'ropsten') {}

};
