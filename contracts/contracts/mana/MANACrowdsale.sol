pragma solidity 0.5.7;

import "../zeppelin/crowdsale/CappedCrowdsale.sol";
import "../zeppelin/crowdsale/Crowdsale.sol";
import "../zeppelin/crowdsale/FinalizableCrowdsale.sol";
import "./WhitelistedCrowdsale.sol";
import "./MANAContinuousSale.sol";
import "./MANAToken.sol";

contract MANACrowdsale is WhitelistedCrowdsale, CappedCrowdsale, FinalizableCrowdsale {

    uint256 public constant TOTAL_SHARE = 100;
    uint256 public constant CROWDSALE_SHARE = 40;
    uint256 public constant FOUNDATION_SHARE = 60;

    // price at which whitelisted buyers will be able to buy tokens
    uint256 public preferentialRate;

    // customize the rate for each whitelisted buyer
    mapping (address => uint256) public buyerRate;

    // initial rate at which tokens are offered
    uint256 public initialRate;

    // end rate at which tokens are offered
    uint256 public endRate;

    // continuous crowdsale contract
    MANAContinuousSale public continuousSale;

    event WalletChange(address wallet);

    event PreferentialRateChange(address indexed buyer, uint256 rate);

    event InitialRateChange(uint256 rate);

    event EndRateChange(uint256 rate);

    constructor(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _initialRate,
        uint256 _endRate,
        uint256 _preferentialRate,
        address payable _wallet
    )
        public
        CappedCrowdsale(86206 ether)
        WhitelistedCrowdsale()
        FinalizableCrowdsale()
        Crowdsale(_startBlock, _endBlock, _initialRate, _wallet)
    {
        require(_initialRate > 0);
        require(_endRate > 0);
        require(_preferentialRate > 0);

        initialRate = _initialRate;
        endRate = _endRate;
        preferentialRate = _preferentialRate;

        continuousSale = createContinuousSaleContract();

        MANAToken(token).pause();
    }

    function createTokenContract() internal returns(MintableToken) {
        return new MANAToken();
    }

    function createContinuousSaleContract() internal returns(MANAContinuousSale) {
        return new MANAContinuousSale(rate, wallet, token);
    }

    function setBuyerRate(address buyer, uint256 rate) onlyOwner public {
        require(rate != 0);
        require(isWhitelisted(buyer));
        require(block.number < startBlock);

        buyerRate[buyer] = rate;

        emit PreferentialRateChange(buyer, rate);
    }

    function setInitialRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(block.number < startBlock);

        initialRate = rate;

        emit InitialRateChange(rate);
    }

    function setEndRate(uint256 rate) onlyOwner public {
        require(rate != 0);
        require(block.number < startBlock);

        endRate = rate;

        emit EndRateChange(rate);
    }

    function getRate() internal returns(uint256) {
        // some early buyers are offered a discount on the crowdsale price
        if (buyerRate[msg.sender] != 0) {
            return buyerRate[msg.sender];
        }

        // whitelisted buyers can purchase at preferential price before crowdsale ends
        if (isWhitelisted(msg.sender)) {
            return preferentialRate;
        }

        // otherwise compute the price for the auction
        uint256 elapsed = block.number - startBlock;
        uint256 rateRange = initialRate - endRate;
        uint256 blockRange = endBlock - startBlock;

        return initialRate.sub(rateRange.mul(elapsed).div(blockRange));
    }

    // low level token purchase function
    function buyTokens(address beneficiary) payable public {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        uint256 rate = getRate();
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = updatedWeiRaised;

        token.mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function setWallet(address payable _wallet) onlyOwner public {
        require(_wallet != address(0));
        wallet = _wallet;
        continuousSale.setWallet(_wallet);
        emit WalletChange(_wallet);
    }

    function unpauseToken() onlyOwner public {
        require(isFinalized);
        MANAToken(token).unpause();
    }

    function pauseToken() onlyOwner public {
        require(isFinalized);
        MANAToken(token).pause();
    }


    function beginContinuousSale() onlyOwner public {
        require(isFinalized);

        token.transferOwnership(continuousSale);

        continuousSale.start();
        continuousSale.transferOwnership(owner);
    }

    function finalization() internal {
        uint256 totalSupply = token.totalSupply();
        uint256 finalSupply = TOTAL_SHARE.mul(totalSupply).div(CROWDSALE_SHARE);

        // emit tokens for the foundation
        token.mint(wallet, FOUNDATION_SHARE.mul(finalSupply).div(TOTAL_SHARE));

        // NOTE: cannot call super here because it would finish minting and
        // the continuous sale would not be able to proceed
    }

}
