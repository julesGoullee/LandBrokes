pragma solidity 0.5.3;

import "contracts/zeppelin/ERC20/MintableToken.sol";

contract DetailedMintableToken is MintableToken {

  string name;
  string symbol;
  uint8 decimals;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {

    name = _name;
    symbol = _symbol;
    decimals = _decimals;

  }

  function getName() public view returns (string memory) {

    return name;

  }

  function getSymbol() public view returns (string memory) {

    return symbol;

  }

  function getDecimals() public view returns (uint8) {

    return decimals;

  }

}
