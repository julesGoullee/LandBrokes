import { FETCH_ACCOUNT } from "../actionTypes";

const initialState = {
  address: '',
  balanceMana: '0',
  balanceInvested: '0',
};

export default function(state = initialState, action) {
  switch (action.type) {
    case FETCH_ACCOUNT: {
      const { address, balanceMana, balanceInvested } = action.payload;
      return {
        ...state,
        address,
        balanceMana,
        balanceInvested
      };
    }
    default:
      return state;
  }
}
