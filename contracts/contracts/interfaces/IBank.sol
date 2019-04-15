pragma solidity 0.5.3;

import "contracts/zeppelin/ownership/Ownable.sol";

contract IBank is Ownable {

  //Functions having onlyOwner are managed by our backend

  event Bid(uint256 landId, address tokenAddress, bytes investorData);
  event CancelledBid(address _tokenAddress, uint256 _tokenId);
  event Deposited(uint256 timestamp, bytes depositType, uint256 amount, address who);
  event Withdrew(uint256 timestamp, bytes withdrawalType, uint256 amount, address who);
  event RegisteredBidResult(uint8 result, address tokenAddress,
    uint256 _tokenId, bytes investorData, address createdSplitLand);
  event SplitExternalLand(address owner, address _tokenAddress,
    uint256 _tokenId, uint256 parts);
  event ReconstructedLand(uint256 id, address caller, address reconstructedLandReceiver);

  struct Land {

    address splitLandToken;

    uint256 parts;

  }

  //Hashed tickers used in splitBalances and wholeBalances
  bytes constant MANA = keccak256("MANA");

  //How many land owners can pool money together at once in order to bid
  uint8 constant MAX_LAND_OWNERS = 30;

  //Maximum number of pieces a patch of LAND can be split in
  uint16 constant MAX_LAND_SPLITS = 10000;

  //When submitting a bid, we specify this duration (which is 1 day less than max amount permitted)
  uint256 BID_DURATION = 181 days;

  //How much MANA was deposited for buying whole plots of LAND without splitting
  uint256 wholeLandMANAFunds;

  //How much MANA was deposited for buying whole plots of LAND and then split them
  uint256 splitLandMANAFunds;

  //Some people want to let us invest for them but only want a fraction of LAND
  mapping(address => mapping(bytes => uint256)) splitBalances;

  //Others want to let us invest for them and target whole plots of LAND
  mapping(address => mapping(bytes => uint256)) wholeBalances;

  //Funds already used in a bid
  mapping(address => mapping(bytes => uint256)) lockedForBidding;

  //LAND id being bid on by us
  mapping(uint256 => bool) beingBid;

  //Details for LAND token deposited in this contract and split; mapping LAND token id to Land struct
  mapping(uint256 => Land) landDetails;

  enum BID_RESULT {SUCCESSFUL, FAILED, CANCELLED};

  enum BALANCE_TYPE {SPLIT, WHOLE};

  /**
  * @dev Bid for land using the Decentraland Bid contract.
         Our backend monitors this smart contract and
         uses the balances that investors entrusted us with to bid for
         the best LAND we can find for sale. We are effectively an investment
         fund for millenials and Gen Zs. They simply send money to this
         contract and we take care to invest it

  * @warn In the investors array we cannot mix those who want only a fraction
          of LAND and those who want a whole plot

  * @param investmentType - SPLIT or WHOLE (we will divide the LAND or we give the entire LAND to one entity)
  * @param landId - The id of the LAND we want to invest in
  * @param tokenAddress - Address of the ERC721 token
  * @param investors - The addresses whose funds we will use to bid
  * @param _amountsInvested - The amount we use from each investor's balance
  */
  function bidForLand(
    uint8 investmentType,
    uint256 landId,
    address tokenAddress,
    address[] investors,
    address[] _amountsInvested)
    external onlyOwner;

  /**
  * @dev Cancel a bid. This function can only be triggered from registerBidResult
  * @param _tokenAddress - Address of the ERC721 token
  * @param _tokenId - The id of the LAND we previously bid for
  **/
  function cancelLandBid(
    address _tokenAddress,
    uint256 _tokenId)
    internal;

  /**
  * @dev Entrust the contract with MANA so it can be invested for you or for someone you deposit for
  * @param balanceType - 0 or 1 (SPLIT OR WHOLE)
  * @param _target - Who receives the MANA in their balance
  * @param _amount - How much MANA is deposited
  **/
  function depositMANA(uint8 balanceType, address _target, uint256 _amount) external;

  /**
  * @dev Withdraw MANA from the contract
  * @param balanceType - 0 or 1 (SPLIT OR WHOLE)
  * @param _amount - How much MANA is being withdrawn
  **/
  function withdrawMANA(uint8 balanceType, uint256 _amount) external;

  /**
  * @dev Register the result of a bid.
         If unsuccessful, transfer funds from locked to either split or
         whole balances. If we want to cancel, call the cancelLandBid
         function and send funds from locked to normal balances.
         If successful and the investors we took money from wanted SPLIT,
         we decrease the amounts from lockedForBidding and we create a
         new SplitLand ERC20 contract where we distribute LAND parts to
         investors. If the investment type is WHOLE, we just send the entire
         LAND to the investor. When distributing LAND parts, each investor
         will get a proportional amount of LAND parts according to how much
         money we used from their balance, compared to total amount invested
         in that LAND.

  * @param result - It can be 0, 1 or 2 (SUCCESSFUL, FAILED, CANCELLED)
  * @param tokenAddress - Address of the ERC721 token
  * @param _tokenId - The id of the LAND we want to invest in
  * @param investorData - 2 arrays packed together using the "encodePacked" web3js function.
           The first array is the investors addresses, the second one is the array
           specifying how many LAND parts each investor will get
  **/
  function registerBidResult(
    uint8 result,
    address tokenAddress,
    uint256 _tokenId,
    bytes investorData)
    external onlyOwner;

  /**
  * @dev Allow anyone to deposit a LAND token in this contract and create
         a SplitLand ERC20 contract where all the LAND parts are assigned
         in the constructor to msg.sender. The LAND token deposited in this contract
         cannot be transferred elsewhere unless someone has all the LAND parts
         in the balance in the SplitLand contract and calls reconstructLand.

         When creating a new SplitContract, create a new Land struct with
         the address of the new contract and how many portions of LAND
         were created.

  * @param tokenAddress - Address of the ERC721 LAND token
  * @param _tokenId - The id of the LAND we want to invest in
  * @param landParts - Needs to be less than or equal to MAX_LAND_SPLITS
                       Tells the newly created SplitLand contract in how
                       many smaller parts we divided the LAND
  **/
  function generalSplitLand(
    address _tokenAddress,
    uint256 _tokenId,
    uint256 landParts)
    external;

  /**
  * @dev Reconstruct and entire LAND token from the LAND parts in a SplitLand
         contract and then send the LAND to reconstructedLandReceiver.
         The msg.sender needs to have all the LAND parts in their balance inside
         the SplitLand contract.

  * @param id - The id of the LAND token the caller wants to reconstruct
  * @param reconstructedLandReceiver - The receiver of the reconstructed LAND token
  **/
  function reconstructLand(
    uint256 id,
    address reconstructedLandReceiver)
    external;

}
