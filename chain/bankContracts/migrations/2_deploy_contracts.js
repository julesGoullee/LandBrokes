var MANAToken = artifacts.require("MANAToken");
var Bank = artifacts.require("Bank");

var Web3 = require('web3');

require('dotenv').config();

var wssInfura = "wss://ropsten.infura.io/ws/v3/"
var httpInfura = "https://ropsten.infura.io/v3/"

var infuraKey = ""

var defaultMANAAmount = "10000000000000000000"

var manaTicker = "MANA"
var maxLandOwners = 30;
var max_land_splits = 10000;
var maxBidDuration = 60 * 60 * 24 * 180; //180 days
var _noActionCancelAfter = 60 * 60 * 24 * 60; //60 days
var _manaToken;
var _decentralandBid = "0x5581364f1350B82Ed4E25874f3727395BF6Ce490";
var _landToken= "0x5581364f1350B82Ed4E25874f3727395BF6Ce490";
var _landRegistry= "0x5581364f1350B82Ed4E25874f3727395BF6Ce490";

module.exports = async function (deployer, network, accounts) {

  var web3 = await getWeb3();

  if (network == 'development') {

    //Deploying savings branch

    deployer.deploy(MANAToken, {from: accounts[0]}).then(function() {

      var mana = await MANAToken.deployed();

      _manaToken = mana.address;

      var encodedBankParams = await encodeBankParams(web3);

      //Give MANA to each address

      for (var i = 0; i < accounts.length; i++) {

        await mana.mint(accounts[0], defaultMANAAmount, {from: accounts[0]})

      }

      return deployer.deploy(Bank, {from: accounts[0]}).then(function() {



      })

    })

  } else if (network == "ropsten") {



  }

}

async function encodeBankParams(web3) {

  var encoded = await
  web3.eth.abi.
  encodeParameters(
    ['string', 'uint8','uint16', 'uint256', 'uint256', 'address', 'address', 'address', 'address'],
    [manaTicker, maxLandOwners, max_land_splits, maxBidDuration, _noActionCancelAfter, _manaToken, _decentralandBid, _landToken, _landRegistry]
  );

  return encoded

}

async function getWeb3() {

  return new Web3(new Web3.providers.HttpProvider(httpInfura + infuraKey));

}
