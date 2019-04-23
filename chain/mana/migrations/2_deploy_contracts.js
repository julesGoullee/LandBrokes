const MANAToken = artifacts.require('MANAToken');

const defaultMANAAmount = '10000000000000000000';

module.exports = async function (deployer, network, accounts) {

  if(network === 'development'){

    //Deploying mana token

    await deployer.deploy(MANAToken, { from: accounts[0] });

    const mana = await MANAToken.deployed();

    //Give MANA to each address

    for(let i = 0; i < accounts.length; i++){

      await mana.mint(accounts[0], defaultMANAAmount, { from: accounts[0] });

    }
  } else if (network === 'ropsten') {}

  console.log(`
   MANAToken: ${MANAToken.address}
  `);

};
