pragma solidity 0.5.3;

import "contracts/zeppelin/ownership/Ownable.sol";

//If our bid is unsuccessful and removed in the Decentraland Bid contract, how do we trustlessly log the fact we got back MANA in the contract?

contract IBank is Ownable {

  event Bid(uint256 landId, address tokenAddress, bytes investorData);
  event CancelledBid(address _tokenAddress, uint256 _tokenId);
  event Deposited(bytes depositType, uint256 amount, address who);
  event Withdrew(bytes withdrawalType, uint256 amount, address who);
  event RegisteredBidResult(uint8 result, address tokenAddress,
    uint256 _tokenId, bytes investorData, address createdSplitLand);
  event SplitExternalLand(address owner, address _tokenAddress,
    uint256 _tokenId, uint256 parts);
  event ReconstructedLand(uint256 id, address caller, address reconstructedLandReceiver);

  struct Land {

    address splitLandToken;

    uint256 parts;

  }

  bytes constant ETH = keccak256("ETH");
  bytes constant MANA = keccak256("MANA");

  uint8 constant MAX_LAND_OWNERS = 30;
  uint16 constant MAX_LAND_SPLITS = 10000;

  uint256 BID_DURATION = 181 days;

  uint256 wholeLandETHFunds;
  uint256 splitLandETHFunds;

  uint256 wholeLandMANAFunds;
  uint256 splitLandMANAFunds;

  mapping(address => mapping(bytes => uint256)) splitBalances;
  mapping(address => mapping(bytes => uint256)) wholeBalances;

  mapping(uint256 => bool) beingBid;

  mapping(uint256 => Land) landDetails;

  enum BID_RESULT {SUCCESSFUL, FAILED, CANCELLED};

  function bidForLand(
    uint256 landId,
    address tokenAddress,
    address[] investors,
    address[] _amountsInvested)
    external onlyOwner;

  function cancelLandBid(address _tokenAddress, uint256 _tokenId) internal;

  function depositETH() external payable;

  function depositMANA(uint256 _amount) external;

  function withdrawETH(uint256 _amount) external;

  function withdrawMANA(uint256 _amount) external;

  function registerBidResult(
    uint8 result,
    address tokenAddress,
    uint256 _tokenId,
    address[] investors,
    uint256[] landParts)
    external onlyOwner;

  function generalSplitLand(
    address _tokenAddress,
    uint256 _tokenId,
    uint256 landParts)
    external;

  function reconstructLand(
    uint256 id,
    address reconstructedLandReceiver)
    external;

}
