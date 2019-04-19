pragma solidity 0.5.7;

import '../zeppelin/ERC20/StandardToken.sol';

contract ISplitLand is StandardToken {

  /**
  *  When a new SplitLand contract is created, in the constructor,
  *  we specify the variables below. In the constructor we also pass
  *  the total supply (which in our Bank contract is max 10K).
  *
  *  We make sure we also pass an array of addresses and a uint256 array
  *  specifying how many tokens (LAND portions) each address will get
  **/

  string name;
  uint8 decimals;
  string symbol;

  uint256 decentralandLandId;

}
