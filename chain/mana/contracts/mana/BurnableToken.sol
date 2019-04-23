pragma solidity 0.5.7;

import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Burnable Token
 * @dev A token that can be irreversibly burned.
 */
contract BurnableToken is ERC20 {

  using SafeMath for uint256;
  using SafeMath for int256;

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specified amount of tokens.
     * @param _value The amount of tokens to burn.
     */
    function burn(uint256 _value) public {

        require(_value > 0);

        _burn(msg.sender, _value);

    }

}
