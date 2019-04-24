const path = require('path');
const Ethers = require('ethers');

const Config = require(path.join(srcDir, '../config') );

const MANATokenABI = require(path.join(srcDir, '../../chain/landSC/build/contracts/MANAToken') ).abi; // eslint-disable-line node/no-unpublished-require
const LANDRegistryABI = require(path.join(srcDir, '../../chain/landSC/build/contracts/LANDRegistry') ).abi; // eslint-disable-line node/no-unpublished-require
const MarketplaceABI = require(path.join(srcDir, '../../chain/landSC/build/contracts/Marketplace') ).abi; // eslint-disable-line node/no-unpublished-require

describe('Bank', () => {

  before( () => {

    this.provider = new Ethers.providers.JsonRpcProvider('http://localhost:8545');
    this.wallet1 = new Ethers.Wallet('0x6cbed15c793ce57650b9877cf6fa156fbef513c4e6134f022a85b1ffdd59b2a1', this.provider);
    this.wallet2= new Ethers.Wallet('0x6370fd033278c143179d81c5526140625662b8daa446c22ee2d73db3707e620c', this.provider);

  });

  beforeEach( () => {

    this.sandbox = createSandbox();

  });

  afterEach( () => {

    this.sandbox && this.sandbox.restore();

  });

  describe('Check state', () => {

    it('Should have mana token', async () => {

      const manaContract = new Ethers.Contract(Config.contractsAddress.development.addressManaToken, MANATokenABI, this.wallet1);
      const manaBalance = await manaContract.balanceOf(this.wallet1.address);
      expect(Ethers.utils.formatEther(manaBalance).toString() ).to.be.eq('10.0');

    });

    it('Should have land', async () => {

      const landProxyContract = new Ethers.Contract(Config.contractsAddress.development.decentralandLandProxy, LANDRegistryABI, this.wallet1);
      const landsCoords = await landProxyContract.landOf(this.wallet1.address);
      expect(landsCoords.length).to.be.gt(0);
      const owner = await landProxyContract.ownerOfLand(landsCoords[0][5].toNumber(), landsCoords[1][5].toNumber());
      expect(owner).to.be.eq(this.wallet1.address);
      // const landData = await landProxyContract.landData(landsCoords[0][5].toNumber(), landsCoords[1][5].toNumber() );

    });

    it('Should sell and buy land on marketplace', async () => {

      const landCoords = [0, 5];
      const landProxyContract = new Ethers.Contract(Config.contractsAddress.development.decentralandLandProxy, LANDRegistryABI, this.wallet1);
      const marketplaceContract = new Ethers.Contract(Config.contractsAddress.development.addressDecentralandMarketplace, MarketplaceABI, this.wallet1);
      const assetId = await landProxyContract.encodeTokenId(...landCoords);
      const price = 12345;

      await landProxyContract.setApprovalForAll(Config.contractsAddress.development.addressDecentralandMarketplace, true, {
        gasLimit: 1000000, // wrong estimation
      });

      const paramsCreateOrder = [
        Config.contractsAddress.development.decentralandLandProxy,
        assetId,
        price,
        parseInt(Date.now() / 1000, 10) + 60 * 30
      ];
      await marketplaceContract['createOrder(address,uint256,uint256,uint256)'](...paramsCreateOrder);

      const owner = await landProxyContract.ownerOfLand(...landCoords);
      expect(owner).to.be.eq(this.wallet1.address);

      const manaContract = new Ethers.Contract(Config.contractsAddress.development.addressManaToken, MANATokenABI, this.wallet2);
      await manaContract.approve(Config.contractsAddress.development.addressDecentralandMarketplace, price);

      const paramsExecuteOrder = [
        Config.contractsAddress.development.decentralandLandProxy,
        assetId,
        price
      ];
      await marketplaceContract.connect(this.wallet2)['executeOrder(address,uint256,uint256)'](...paramsExecuteOrder);

      const newOwner = await landProxyContract.ownerOfLand(...landCoords);
      expect(newOwner).to.be.eq(this.wallet2.address);

    });

  });

});
