pragma solidity 0.5.3;

import "contracts/zeppelin/ownership/Ownable.sol";

contract ICreditScoring is Ownable {

  enum BACKING_TYPE {ERC20, ERC721}

  enum REQUEST_STATUS {STARTED, CANCELLED, CREATED}

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

    //The address of the ERC20 token offered as payment to the lender
    address coinOffered;

    //How many ERC20 tokens will be paid for the credit points borrowed
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

    //The personal credit score of a user
    uint256 personalScore;

    //How many points this user borrowed since the beginning of their activity
    uint256 borrowedPoints;

    //How many points this user lent since the beginning of their activity
    uint256 allTimeLentPoints;

    //How many points this user is lending right now
    uint256 currentlyLentPoints;

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

  //How many seconds an address can keep some borrowed credit points
  uint256 public BORROWED_KEEPING_TIME_LIMIT;

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

  //needs onlyOwner

  /**
  * @dev Set points for a certain criteria and a level as outlined here:
  *      http://tiny.cc/oeba5y
  *
  * @param elementName - A string denoting the criteria. Ex: "Deposit history",
                         "Investing history length"
  * @param elementOption - The level for a criteria. Ex: for Deposit history
                           there are 5 different levels, so we can make
                           elementOption any number between 0 - 4
  * @param score - The points given for the level on this criteria
  **/

  function setCardOption(
    string calldata elementName,
    uint256 elementOption,
    int256 score
  ) external;

  //needs onlyOwner

  /**
  * @dev Whitelist a coin to be used as collateral or as payment for lending credit points.
         If a coin is already set to true, it will be set to false and vice-versa

  * @param coin - The address of the token contract we toggle
  **/

  function toggleWhitelistedCoin(
    address coin
  ) external;

  //needs onlyOwner

  /**
  * @dev Set how many seconds any request can stay active from its creation onward

  * @param _secondAmount - Number of seconds
  **/

  function changeMaxRequestAvailability(
    uint256 _secondAmount
  ) external;

  //needs onlyOwner

  /**
  * @dev How many credit points an address can borrow at any time

  * @param points - The max number of credit points an address can borrow at any point in time
  **/

  function changeMaxBorrowedPoints(
    uint256 points
  ) external;

  /**
  * @dev Get your credit score. The elements array is made out of the level
         the user is at in each category. For example, if we determine off-chain
         that the user has the following:

         Deposit history: 6 - 10 weeks
         Investing history length: Below 6 months - 10 points
         Bank spam: 0
         Mortgages seeked in the last 6 months: 2 - 5
         Outstanding debt: 501 - 10K MANA
         Times defaulted: 0 times

         then the user would need to pass the array:

         [2, 1, 0, 1, 2, 0]

         The function (for now) simply returns the sum of the points
         mapped to each level from each category. In this case,

         30 + 10 + 30 + 30 + 20 + 70 = 190 (credit points)

  * @param elements - The array of levels for each category as explained above

  **/

  function computeCreditScore(
    uint256[] calldata elements)
    external view returns (uint256);

  //needs onlyOwner

  /**
  * @dev This function does the same thing as computeCreditScore but with an addition.
         It stores the score in the personalScore field inside the user's struct.
         Note that only the owner can call this because a user can put random numbers
         in the elements array and artificially boost their score. As a proof to show
         that they chose the correct params in the elements array, the owner
         needs to specify an IPFS address where the credit data for an address is stored
         and acts as proof.

  * @param user - The address of the user we compute for
  * @param elements - The array of levels for each category as explained in computeCreditScore
  * @param ipfsCreditDataProof - IPFS hash pointing to credit data that serves as proof
                                 ipfsCreditDataProof needs to be emitted in an event

  **/

  function computeAndUpdateScore(
    address user,
    uint256[] calldata elements,
    string calldata ipfsCreditDataProof
  ) external;

  /**
  * @dev A user can register in the CreditScoring contract. Registration is needed
         to initialize the user's struct where we store their data.
  **/

  function registerUser() external;

  /**
  * @dev Request credit points.

  * @param _lendingDuration - How many seconds this address wants to keep the borrowed points
  * @param _askData - The encoded ASK parameters (ASK params are detailed in CreditRequest)
  * @param _offerData - The encoded OFFER parameters (OFFER params are detailed in CreditRequest)
  **/

  function requestCreditPoints(
    uint256 _lendingDuration,
    bytes calldata _askData,
    bytes calldata _offerData
  ) external;

  /**
  * @dev Fill a credit points request. We need to check that the lender is currently
         lending at max MAX_LENT_CREDIT_POINTS and they are not going above the
         limit by also lending for this request. The number of points being
         asked for in the request will be decreased from the lender's personalScore
         and increased in their currentlyLentPoints
  **/

  function fillRequest() external;

  /**
  * @dev Cancel a request. Only the creator can cancel. Also the creator cannot
         cancel if a request has already been filled. Finally, the creator needs
         to wait minCancelRequestDelay seconds since the creation of the request
         in order to cancel it
  **/

  function cancelRequest(
    uint256 position
  ) external;

  /**
  * @dev Change the address of the token offered to the lender in exchange
         for their credit points

  * @param position - The position of the request in creditRequests
  * @param newCoinOffered - The address of the new ERC20 offered; the ERC20 needs to be whitelisted
  **/

  function changeRequestCoinOffered(
    uint256 position,
    address newCoinOffered
  ) external;

  /**
  * @dev Change how many ERC20 coins the borrower offers for credit points

  * @param position - The position of the request in creditRequests
  * @param coinAmount - New ERC20 amount to be paid toward the lender
  **/

  function changeRequestCoinAmountOffered(
    uint256 position,
    uint256 coinAmount
  ) external;

  

  function payBackDebt(
    uint256 position,
    uint256 _coinAmount
  ) external;

  function borrowerGetBackCollateral(
    uint256 position
  ) external;

  function punishBorrowerNonPayment(
    uint256 position
  ) external;

}
