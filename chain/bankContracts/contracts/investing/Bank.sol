pragma solidity 0.5.7;

import "contracts/interfaces/IBank.sol";
import "contracts/zeppelin/ContractDetector.sol";
import "contracts/zeppelin/SafeMath.sol";

contract Bank is IBank, ContractDetector {

  using SafeMath for uint256;
  using SafeMath for int256;

  constructor(
    string memory manaTicker,
    uint256 maxLandOwners,
    uint256 max_land_splits,
    uint256 maxBidDuration,
    uint256 noActionCancelBidAfter,
    address _manaToken,
    address _landToken,
    address _decentralandBid) {

      require(maxLandOwners > 0, "You need a positive number of land owners");
      require(max_land_splits > 0, "You need a positive number of land splits");
      require(maxBidDurationlandIsInBank > 0, "The bid duration needs to be positive");
      require(noActionCancelBidAfter > 0, "noActionCancelBidAfter has to be positive");
      require(isContract(_manaToken) == true, "The _manaToken is not a contract address");
      require(isContract(_landToken) == true, "The _landToken is not a contract address");
      require(isContract(_decentralandBid) == true, "The _decentralandBid is not a contract address");

      MANA = keccak256(manaTicker);
      MAX_LAND_OWNERS = maxLandOwners;
      MAX_LAND_SPLITS = max_land_splits;
      BID_DURATION = maxBidDuration;
      NO_ACTION_CANCEL_BID_AFTER = noActionCancelBidAfter;
      manaToken = MANAToken(_manaToken);
      landAddress = _landToken;
      decentralandBid = Bid(_decentralandBid);

    }

    function changeMaxLandOwners(uint256 maxLandOwners) external onlyOwner {

      require(maxLandOwners > 0, "You need a positive number of land owners");

      MAX_LAND_OWNERS = maxLandOwners;

    }

    function changeMaxLandSplits(uint256 max_land_splits) external onlyOwner {

      require(max_land_splits > 0, "You need a positive number of land splits");

      MAX_LAND_SPLITS = max_land_splits;

    }

    function changeBidDuration(uint256 maxBidDuration) external onlyOwner {

      require(maxBidDuration > 0, "The bid duration needs to be positive");

      BID_DURATION = maxBidDuration;

    }

    function changeNoActionCancelTime() external onlyOwner {

      require(noActionCancelBidAfter > 0, "noActionCancelBidAfter has to be positive");

      NO_ACTION_CANCEL_BID_AFTER = noActionCancelBidAfter;

    }

    function bidForLand(
      uint8 investmentType,
      uint256 landId,
      address[] calldata investors,
      address[] calldata _amountsInvested)
      external {

      require(investmentType <= 1, "The investment type needs to be between bounds");
      require(investors.length == _amountsInvested.length,
        "The investors and _amountsInvested arrays do not have the same length");
      require(landIsInBank[landId] == false, "The land specified is already owned by the bank");

      if (investmentType == 0) {

        require(investors.length == 1,
          "With a whole investment there needs to be only 1 investor");

      } else if (investmentType == 1) {

        require(investors.length >= 0,
          "With a split investment there needs to be a positive amount of investors");

      }

      uint256 totalToInvest = 0;

      for (uint i = 0; i < _amountsInvested.length; i++) {

        totalToInvest = totalToInvest.add(_amountsInvested[i]);

      }

      if (investmentType == 0) {

        require(wholeLandMANAFunds >= totalToInvest,
          "The is not enough MANA for whole investments");

        wholeBalances[investors[0]][MANA] =
          wholeBalances[investors[0]][MANA].sub(_amountsInvested[0]);

        lockedForBidding[investors[0]][MANA] =
          lockedForBidding[investors[0]][MANA].add(_amountsInvested[0]);

      } else if (investmentType == 1) {



      }

      uint256 currentlyApproved =
        manaToken.allowance(address(this), address(decentralandBid));

      //Mitigate front-running
      manaToken.approve(address(decentralandBid), 0);

      //Allow the bid contract to get MANA from this contract
      manaToken.approve(address(decentralandBid),
                        currentlyApproved.add(totalToInvest));

      decentralandBid.placeBid(
        landAddress,
        landId,
        totalToInvest,
        BID_DURATION
      );



    }

}
