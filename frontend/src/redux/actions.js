import assert from 'assert';
import * as Ethers from 'ethers';
import { TOGGLE_SIDEBAR, FETCH_ACCOUNT, UPDATE_ALLOWANCE} from "./actionTypes";
import Config from '../config';

import MANAToken from '../contracts/decentraland/MANAToken';
import LANDRegistry from '../contracts/decentraland/LANDRegistry';

import Bank from '../contracts/IBank';
import SplitLand from '../contracts/ISplitLand';

let provider = null;
let wallet = null;
let contractBank = null;
let contractMana = null;
let isInit = false;

export function toggleSidebar(){
  return {
    type: TOGGLE_SIDEBAR
  }
}

async function _setAccount(){

  if(isInit){

    return true;

  }

  const { web3 } = window;
  assert(web3, 'web3_not_defined');
  provider =  new Ethers.providers.Web3Provider(web3.currentProvider);

  const accounts = await provider.listAccounts();
  wallet = provider.getSigner(accounts[0]); //TODO watch address change https://www.npmjs.com/package/react-web3
  contractMana = new Ethers.Contract(Config.contractsAddress[Config.network].addressManaToken, MANAToken.abi, wallet);
  contractBank = new Ethers.Contract(Config.contractsAddress[Config.network].addressBank, Bank.abi, wallet);

  isInit = true;


}

export function fetchAccount() {

  return async (dispatch) => {

    await _setAccount();
    assert(isInit, 'web3_not_initialized');

    const address = await wallet.getAddress();

    const balanceMana = await contractMana.balanceOf(address);
    const balanceInvested = await contractBank.getSplitBalance(address, Ethers.utils.formatBytes32String(Config.tokenTicker) );

    const allowanceManaValue = await contractMana.allowance(address, Config.contractsAddress[Config.network].addressBank);

    dispatch({
      type: FETCH_ACCOUNT,
      payload: {
        address,
        balanceMana: balanceMana.toString(),
        balanceInvested: balanceInvested.toString(),
        allowanceMana: allowanceManaValue.toString()
      }
    });

  }

}

export function allowMana(){

  return async (dispatch, getState) => {

    const state = getState();

    if(state.account.allowanceMana !== '0'){

      return true;

    }

    const tx = await contractMana.approve(Config.contractsAddress[Config.network].addressBank, Config.amountAllowance);

    await tx.wait();

    dispatch({
      type: UPDATE_ALLOWANCE,
      payload: {
        allowanceMana: true
      }
    });

  }

}

export function invest(){

  return async (dispatch, getState) => {


  }

}
