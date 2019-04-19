pragma solidity 0.5.7;

import "../zeppelin/ownership/Ownable.sol";
import "./ContinuousSale.sol";
import "./MANAToken.sol";

contract MANAContinuousSale is ContinuousSale, Ownable {

    uint256 public constant INFLATION = 8;

    bool public started = false;

    event RateChange(uint256 amount);

    event WalletChange(address wallet);

    constructor(
        uint256 _rate,
        address payable _wallet,
        MintableToken _token
    ) public ContinuousSale(_rate, _wallet, _token) {
    }

    modifier whenStarted() {
        require(started);
        _;
    }

    function start() onlyOwner public {
        require(!started);

        // initialize issuance
        uint256 finalSupply = token.totalSupply();
        uint256 annualIssuance = finalSupply.mul(INFLATION).div(100);
        //        issuance = annualIssuance.mul(BUCKET_SIZE).div(1 years); // ask stefan
        issuance = annualIssuance.mul(BUCKET_SIZE).div(365 days); // ask stefan
        started = true;
    }

    function buyTokens(address beneficiary) whenStarted public payable {
        super.buyTokens(beneficiary);
    }

    function setWallet(address payable _wallet) onlyOwner public {
        require(_wallet != address(0));
        wallet = _wallet;
        emit WalletChange(_wallet);
    }

    function setRate(uint256 _rate) onlyOwner public {
        rate = _rate;
        emit RateChange(_rate);
    }

    function unpauseToken() onlyOwner public {
        MANAToken(token).unpause();
    }

    function pauseToken() onlyOwner public {
        MANAToken(token).pause();
    }
}
