pragma solidity 0.5.7;

contract ContractDetector {

  constructor() public {}

  function isContract(address _addr) public returns (bool isContract) {

    uint32 size;

    assembly {
      size := extcodesize(_addr)
    }

    return (size > 0);

  }

}
