pragma solidity 0.5.3;

contract ICreditScoring {

  enum BACKING_TYPE {ERC20, ERC721}

  struct ScoreCardElement {



  }

  struct Score {



  }

  struct LentCredit {

    uint256 points;

    uint256 timestamp;

    uint256 duration;

    uint8 backingType;

    address backingLocation;

    address[] uniqueBackingIds;

    uint256 backingAmount;

  }

  mapping(address => mapping(address => ))
  mapping(address => uint256) scores;

  ScoreCardElement[] elements;

  function computeCreditScore(
    bytes elements)
    public view returns (uint256);

}
