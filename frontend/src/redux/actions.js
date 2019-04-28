import { FETCH_ACCOUNT, TOGGLE_SIDEBAR} from "./actionTypes";
import assert from 'assert';
import * as Ethers from 'ethers';

let provider = null;
let wallet = null;
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

  isInit = true;


}

export function fetchAccount (){

  return async (dispatch) => {

    await _setAccount();
    assert(isInit, 'web3_not_initialized');

    const address = await wallet.getAddress();

    dispatch({
      type: FETCH_ACCOUNT,
      payload: {
        address,
        balanceMana: '1',
        balanceInvested: '0'
      }
    });

  }

}

