pragma solidity 0.5.7;

import "contracts/zeppelin/ERC20/ERC20Pausable.sol";
import "contracts/zeppelin/ERC20/MintableToken.sol";
import "contracts/mana/BurnableToken.sol";

contract MANAToken is BurnableToken, ERC20Pausable, MintableToken {

    string public constant symbol = "MANA";

    string public constant name = "Decentraland MANA";

    uint8 public constant decimals = 18;

    function burn(uint256 _value) whenNotPaused public {
        super.burn(_value);
    }
}
