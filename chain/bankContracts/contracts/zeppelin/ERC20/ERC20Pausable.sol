pragma solidity 0.5.7;

import "./ERC20/ERC20.sol";
import "../Pausable.sol";

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool) {
        return increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool) {
        return decreaseAllowance(spender, subtractedValue);
    }
}
