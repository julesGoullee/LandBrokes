pragma solidity 0.5.3;

import "contracts/zeppelin/ERC20/StandardToken.sol";

contract ISplitLand is StandardToken {

  string name;
  uint8 decimals;
  string symbol;

  uint256 decentralandLandId; 

}
