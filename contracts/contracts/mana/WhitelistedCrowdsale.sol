pragma solidity 0.5.7;

import '../zeppelin/SafeMath.sol';
import '../zeppelin/crowdsale/Crowdsale.sol';

/**
 * @title WhitelistedCrowdsale
 * @dev Extension of Crowsdale where an owner can whitelist addresses
 * which can buy in crowdsale before it opens to the public 
 */
contract WhitelistedCrowdsale is Crowdsale, Ownable {
    using SafeMath for uint256;

    // list of addresses that can purchase before crowdsale opens
    mapping (address => bool) public whitelist;

    function addToWhitelist(address buyer) public onlyOwner {
        require(buyer != address(0));
        whitelist[buyer] = true; 
    }

    // @return true if buyer is whitelisted
    function isWhitelisted(address buyer) public pure returns (bool) {
        return whitelist[buyer];
    }

    // overriding Crowdsale#validPurchase to add whitelist logic
    // @return true if buyers can buy at the moment
    function validPurchase() internal view returns (bool) {
        // [TODO] issue with overriding and associativity of logical operators
        return super.validPurchase() || (!hasEnded() && isWhitelisted(msg.sender)); 
    }

}
