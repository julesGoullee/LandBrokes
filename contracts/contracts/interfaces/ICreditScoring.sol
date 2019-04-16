pragma solidity 0.5.3;

import "contracts/zeppelin/ownership/Ownable.sol";

contract ICreditScoring is Ownable {

  enum BACKING_TYPE {ERC20, ERC721}

  enum REQUEST_STATUS {STARTED, CANCELLED, CREATED};

  struct CreditRequest {

    //ASK

  /*
    //What type of collateral the borrower deposited (ERC721 or ERC20)
    uint8 borrowerBackingType;

    //How many credit points the borrower wants
    uint256 borrowedPoints;

    //In case the collateral is ERC20, we specify how much of the coin is staked
    uint256 borrowerBackingAmount;

    //Serialized array of uint256 symbolizing ERC721 token ids; the serialization is done with the "encode" function from web3js
    bytes borrowerUniqueBackingIds;

    //The address of the coin used as collateral
    address borrowerBackingLocation;
  */

    //OFFER

  /*

    address coinOffered;

    uint256 coinAmountOffered;

  */

    uint8 requestStatus;

    //When the request was created
    uint256 creationTime;

    //How many seconds a borrower wants to keep the credit points
    uint256 lendingDuration;

    address borrower;

    address lender;

    /**
    * The encoded ASK params
    * (borrowerBackingType, borrowedPoints, borrowerBackingAmount,
    * borrowerUniqueBackingIds, borrowerBackingLocation)
    **/
    bytes askData;

    /**
    * The encoded OFFER params
    * (coinOffered, coinAmountOffered)
    **/
    bytes offerData;

  }

  struct User {

    uint256 personalScore;

    uint256 borrowedPoints;

    uint256 lentPoints;

  }

  address constant public ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

  //Set this to 4 weeks in the constructor and we can change it with a function
  uint256 public maxRequestAvailability;

  //Minimum amount of time that needs to pass until someone can cancel a request; set this to around 3 days
  uint256 public minCancelRequestDelay;

  //Set to something like 100 in the constructor; denoted maximum amount of credit points someone can have borrowed at one time
  uint256 public MAX_BORROWED_CREDIT_POINTS;

  //Set to something like 50 in the constructor; denoted maximum amount of credit points someone can have lent at one time
  uint256 public MAX_LENT_CREDIT_POINTS;

  /*
  * The borrower needs to wait at least this many seconds after a
  * filled request matures so they can be punished in case they used credit points
  * to do something reckless
  */
  uint256 public WAIT_FOR_COLLATERAL_RETREIVAL;

  /**
  *  After the contract is initialized, we need to setup the scorecard as detailed at:
  *  http://tiny.cc/oeba5y
  *  For example, for Deposit history and option 0 - 5 weeks we have
  *  scorecard["DEPOSIT_HISTORY"][1] which equals 55
  *  For Deposit history and option 6 - 10 weeks we have
  *  scorecard["DEPOSIT_HISTORY"][2] which equals 30
  **/
  mapping(string => mapping(uint256 => int256)) scorecard;

  mapping(address => bool) whitelistedCoins;

  mapping(address => User) users;

  CreditRequest[] public creditRequests;

  function setCardOption(
    string memory elementName,
    uint256 elementOption,
    int256 score
  ) external onlyOwner;

  function toggleWhitelistedCoin(
    address coin
  ) external onlyOwner;

  function changeMaxRequestAvailability(
    uint256 _secondAmount
  ) external onlyOwner;

  function changeMaxBorrowedPoints(
    uint256 points
  ) external onlyOwner;

  function computeCreditScore(
    uint256[] memory elements)
    public view returns (uint256);

  function computeAndUpdateScore(
    uint256[] memory elements) external;

  function registerUser() external;

  function requestCreditPoints(
    uint8 _requestStatus,
    uint256 _creationTime,
    uint256 _lendingDuration,
    address _borrower,
    address _lender,
    bytes memory _askData,
    bytes memory _offerData
  ) external;

  function fillRequest(
    bytes memory _lenderCollateral
  ) public;

  function cancelRequest(
    uint256 position
  ) public;

  function changeRequestCoinOffered(
    uint256 position,
    address newCoinOffered
  ) public;

  function changeRequestCoinAmountOffered(
    uint256 position,
    uint256 coinAmount
  ) public;

  function payBackDebt(
    uint256 position,
    uint256 _coinAmount
  ) public;

  function borrowerGetBackCollateral(
    uint256 position
  ) public;

  function punishBorrowerNonPayment(
    uint256 position
  ) public;



}
