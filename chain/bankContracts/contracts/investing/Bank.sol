pragma solidity ^0.5.7;

//import "./.././interfaces/IBid.sol";
import "./.././interfaces/IBank.sol";
import "../../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/openzeppelin-solidity/contracts/utils/Address.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Bank is IBank, Ownable {

  using SafeMath for uint256;
  using SafeMath for int256;
  using Address for address;

  //IBid decentralandBid;

  address decentralandBid;

  modifier checkBeforeBuying(uint8 investmentType,
                             uint256 investorsLength,
                             uint256 amountsInvestedLength,
                             uint256 landId) {

    require(investmentType <= 1, "The investment type needs to be between bounds");
    require(investorsLength == amountsInvestedLength,
      "The investors and _amountsInvested arrays do not have the same length");
    require(landIsInBank[landId] == false, "The land specified is already owned by the bank");

    if (investmentType == 0) {

      require(investorsLength == 1,
        "With a whole investment there needs to be only 1 investor");

    } else if (investmentType == 1) {

      require(investorsLength >= 0,
        "With a split investment there needs to be a positive amount of investors");

    }

    _;

  }

  constructor(
    /*string memory manaTicker,
    uint8 maxLandOwners,
    uint16 max_land_splits,
    uint256 maxBidDuration,
    uint256 _noActionCancelAfter,
    address _manaToken,
    address _landToken,
    address _decentralandBid,
    address _landRegistry*/
    bytes memory initializationData
  ) public {

      string memory manaTicker;
      uint8 maxLandOwners;
      uint16 max_land_splits;
      uint256 maxBidDuration;
      uint256 _noActionCancelAfter;
      address _manaToken;
      address _landToken;
      address _decentralandBid;
      address _landRegistry;

      (manaTicker, maxLandOwners, max_land_splits,
      maxBidDuration, _noActionCancelAfter, _manaToken,
      _landToken, _decentralandBid, _landRegistry) =
      abi.decode(initializationData,
      (string, uint8, uint16, uint256, uint256, address, address, address, address));

      require(maxLandOwners > 0, "You need a positive number of land owners");
      require(max_land_splits > 0, "You need a positive number of land splits");
      require(maxBidDuration > 0, "The bid duration needs to be positive");
      require(_noActionCancelAfter > 0, "_noActionCancelAfter has to be positive");

      MANA = keccak256(abi.encode(manaTicker));
      MAX_LAND_OWNERS = maxLandOwners;
      MAX_LAND_SPLITS = max_land_splits;
      BID_DURATION = maxBidDuration;
      NO_ACTION_CANCEL_BID_AFTER = _noActionCancelAfter;
      manaToken = MANAToken(_manaToken);
      landAddress = _landToken;
      landRegistry = _landRegistry;
      //decentralandBid = IBid(_decentralandBid);

      decentralandBid = _decentralandBid;

    }

    function changeMaxLandOwners(uint8 maxLandOwners) external onlyOwner {

      require(maxLandOwners > 0, "You need a positive number of land owners");

      MAX_LAND_OWNERS = maxLandOwners;

    }

    function changeMaxLandSplits(uint16 max_land_splits) external onlyOwner {

      require(max_land_splits > 0, "You need a positive number of land splits");

      MAX_LAND_SPLITS = max_land_splits;

    }

    function changeBidDuration(uint256 maxBidDuration) external onlyOwner {

      require(maxBidDuration > 0, "The bid duration needs to be positive");

      BID_DURATION = maxBidDuration;

    }

    function changeNoActionCancelTime(uint256 _noActionCancelAfter) external onlyOwner {

      require(_noActionCancelAfter > 0, "_noActionCancelAfter has to be positive");

      NO_ACTION_CANCEL_BID_AFTER = _noActionCancelAfter;

    }

    function bidForLand(
      uint8 investmentType,
      uint256 landId,
      address[] calldata investors,
      uint256[] calldata _amountsInvested)
      external
      onlyOwner()
      checkBeforeBuying(investmentType, investors.length,
                        _amountsInvested.length, landId) {

      uint256 totalToInvest = computeTotalInvested(_amountsInvested);

      if (investmentType == 0) {

        require(wholeLandMANAFunds >= totalToInvest,
          "The is not enough MANA for whole investments");

        wholeLandMANAFunds = wholeLandMANAFunds.sub(totalToInvest);

        wholeBalances[investors[0]][MANA] =
          wholeBalances[investors[0]][MANA].sub(_amountsInvested[0]);

        lockedForBidding[investors[0]][MANA] =
          lockedForBidding[investors[0]][MANA].add(_amountsInvested[0]);

      } else if (investmentType == 1) {

        require(splitLandMANAFunds >= totalToInvest,
          "The is not enough MANA for split investments");

        splitLandMANAFunds = splitLandMANAFunds.sub(totalToInvest);

        for (uint j = 0; j < investors.length; j++) {

          splitBalances[investors[j]][MANA] =
            splitBalances[investors[j]][MANA].sub(_amountsInvested[j]);

          lockedForBidding[investors[j]][MANA] =
            lockedForBidding[investors[j]][MANA].add(_amountsInvested[j]);

        }

      }

      uint256 currentlyApproved =
        manaToken.allowance(address(this), decentralandBid);

      //Mitigate front-running
      manaToken.approve(decentralandBid, 0);

      //Allow the bid contract to get MANA from this contract
      manaToken.approve(decentralandBid,
                        currentlyApproved.add(totalToInvest));

      bool status;
      bytes memory result;

      //Call the executeOrder function from the marketplace
      (status, result) = decentralandBid.call(
              abi.encode(
              bytes4(keccak256("placeBid(address, uint256, uint256, uint256)")),
              landAddress,
              landId,
              totalToInvest,
              BID_DURATION));

      /*decentralandBid.placeBid(
        landAddress,
        landId,
        totalToInvest,
        BID_DURATION
      );*/

      require(status == true, "Could not bid for LAND");

      emit ProcessedBid(landId, totalToInvest, BID_DURATION);

    }

    function directBuyLand(
      address marketplace,
      uint8 investmentType,
      uint256 landId,
      address[] calldata investors,
      uint256[] calldata _amountsInvested
    ) external onlyOwner
      checkBeforeBuying(investmentType, investors.length,
                      _amountsInvested.length, landId) {

      uint256 totalToInvest = computeTotalInvested(_amountsInvested);

      if (investmentType == 0) {

        require(wholeLandMANAFunds >= totalToInvest,
          "The is not enough MANA for whole investments");

        wholeLandMANAFunds = wholeLandMANAFunds.sub(totalToInvest);

        wholeBalances[investors[0]][MANA] =
          wholeBalances[investors[0]][MANA].sub(_amountsInvested[0]);

      } else if (investmentType == 1) {

        require(splitLandMANAFunds >= totalToInvest,
          "The is not enough MANA for split investments");

        splitLandMANAFunds = splitLandMANAFunds.sub(totalToInvest);

        for (uint j = 0; j < investors.length; j++) {

          splitBalances[investors[j]][MANA] =
            splitBalances[investors[j]][MANA].sub(_amountsInvested[j]);

        }

      }

      //Mitigate front-running
      manaToken.approve(marketplace, 0);

      //Allow the bid contract to get MANA from this contract
      require(manaToken.approve(marketplace, totalToInvest) == true,
        "Could not approve MANA to directly buy LAND");

      bool status;
      bytes memory result;

      //Call the executeOrder function from the marketplace
      (status, result) = marketplace.call(
              abi.encode(
              bytes4(keccak256("executeOrder(address, uint256, uint256)")),
              landAddress,
              landId, totalToInvest));

      require(status == true, "Could not buy LAND");

      bytes memory encodedInvestors =
        abi.encode(investors, _amountsInvested, investmentType);

      unassignedLand[landId] = encodedInvestors;

      emit BoughtLand(landId);

    }

    function assignLand(uint256 unassignedLandId) external onlyOwner {

      address[] memory investors;
      uint256[] memory money;
      uint8 investmentType;

      (investors, money, investmentType) =
        abi.decode(unassignedLand[unassignedLandId],
                   (address[], uint256[], uint8));

      if (investmentType == 0) {

        bool status;
        bytes memory result;

        //Call the executeOrder function from the marketplace
        (status, result) = landRegistry.call(
                abi.encode(
                bytes4(keccak256("transferFrom(address, address, uint256)")),
                address(this),
                investors[0],
                unassignedLandId));

        require(status == true, "Could not transfer the whole LAND to the investor");

      } else {



      }

    }

    function depositMANA(uint8 balanceType, address _target, uint256 _amount) external {

      require(manaToken.balanceOf(msg.sender) >= _amount,
        "You do not have that much MANA to deposit");

      require(balanceType <= 1, "The balance type needs to be 0 or 1");

      manaToken.transferFrom(msg.sender, address(this), _amount);

      if (balanceType == 0) {

        wholeBalances[_target][MANA] =
          wholeBalances[_target][MANA].add(_amount);

        wholeLandMANAFunds = wholeLandMANAFunds.add(_amount);

      } else {

        splitBalances[_target][MANA] =
          splitBalances[_target][MANA].add(_amount);

        splitLandMANAFunds = splitLandMANAFunds.add(_amount);

      }

      emit DepositedMANA(balanceType, msg.sender, _target, _amount);

    }

    function withdrawMANA(uint8 balanceType, uint256 _amount) external {

      require(balanceType <= 1, "The balance type needs to be 0 or 1");

      if (balanceType == 0) {

        require(wholeBalances[msg.sender][MANA] >= _amount,
          "You do not have that much MANA for whole investments");

        wholeBalances[msg.sender][MANA] =
          wholeBalances[msg.sender][MANA].sub(_amount);

        wholeLandMANAFunds = wholeLandMANAFunds.sub(_amount);

      } else {

        require(splitBalances[msg.sender][MANA] >= _amount,
          "You do not have that much MANA for split investments");

        splitBalances[msg.sender][MANA] =
          splitBalances[msg.sender][MANA].sub(_amount);

        splitLandMANAFunds = splitLandMANAFunds.sub(_amount);

      }

      require(manaToken.transfer(msg.sender, _amount) == true,
        "Could not transfer money in the withdraw function");

      emit WithdrewMANA(balanceType, msg.sender, _amount);

    }

    //PRIVATE

    function computeTotalInvested(uint256[] memory _amountsInvested) private pure returns (uint256) {

      uint256 totalToInvest = 0;

      for (uint i = 0; i < _amountsInvested.length; i++) {

        totalToInvest = totalToInvest.add(_amountsInvested[i]);

      }

      return totalToInvest;

    }

}
