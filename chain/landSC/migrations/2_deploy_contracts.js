const ESTATE_NAME = 'Estate';
const ESTATE_SYMBOL = 'EST';

// const LAND_NAME = 'Decentraland LAND';
// const LAND_SYMBOL = 'LAND';

const LANDRegistry = artifacts.require('LANDRegistry');
const EstateRegistry = artifacts.require('EstateRegistry');
const LANDProxy = artifacts.require('LANDProxy');

module.exports = async function (deployer, network, accounts) {

  if(network === 'development'){

    await deployer.deploy(LANDProxy, { from: accounts[0] });
    await deployer.deploy(LANDRegistry, { from: accounts[0] });

    const landProxy = await LANDProxy.deployed();
    const landRegistry = await LANDRegistry.deployed();

    await landProxy.upgrade(landRegistry.address, accounts[0], { from: accounts[0] });

    await deployer.deploy(EstateRegistry, ESTATE_NAME, ESTATE_SYMBOL, landProxy.address, { from: accounts[0] });

    const estate = await EstateRegistry.deployed();

    const land = await LANDRegistry.at(landProxy.address);
    await land.initialize(accounts[0], { from: accounts[0] });
    await land.setEstateRegistry(estate.address);

    await land.authorizeDeploy(accounts[0], { from: accounts[0] });

    for(let i = 0; i < 15; i++){

      await land.assignNewParcel(0, i, accounts[1], { from: accounts[0] });
      await land.assignNewParcel(1, i, accounts[2], { from: accounts[0] });
      await land.assignNewParcel(2, i, accounts[3], { from: accounts[0] });

    }

    await land.ping({ from: accounts[1] });
    await land.ping({ from: accounts[2] });
    await land.ping({ from: accounts[3] });

  } else if (network === "ropsten") {}

};
