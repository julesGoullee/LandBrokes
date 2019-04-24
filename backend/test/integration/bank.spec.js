const path = require('path');
const Ethers = require('ethers');
const Decimal = require('decimal.js');

const Config = require(path.join(srcDir, '../config') );
const Utils = require(path.join(srcDir, '/modules/utils') );
const Bank = require(path.join(srcDir, '/modules/bank') );
const LANDRegistryContractABI = require(path.join(srcDir, '../../chain/landSC/build/contracts/ILANDRegistry') ).abi; // eslint-disable-line node/no-unpublished-require

describe('Bank', () => {

  before( () => {

    this.addressManaToken = '0x5b1869D9A4C187F2EAa108f3062412ecf0526b24';
    Config.contractsAddress.development.decentralandMarketplaceContract = '0xfE82e8f24A51E670133f4268cDfc164c49FC3b37';
    Config.contractsAddress.development.addressContractBank = '0x6f84742680311CEF5ba42bc10A71a4708b4561d1';
    Config.privateKey = '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d';

  });

  beforeEach( () => {

    this.sandbox = createSandbox();

  });

  afterEach( () => {

    this.sandbox && this.sandbox.restore();

  });

  it('Should invest', async () => {

    const bank = new Bank();
    await bank.init();

  });

});
