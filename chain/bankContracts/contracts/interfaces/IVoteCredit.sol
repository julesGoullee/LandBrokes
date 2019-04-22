pragma solidity 0.5.7;

contract IVoteCredit {

  uint256 proposalNonce;

  mapping(uint256 => Proposal) proposals;

  mapping(uint256 => uint256) votes;

  enum PROPOSAL_TYPES {MODIFY, CREATE, REMOVE}

  enum PROPOSAL_STAGE {ONGOING, CANCELLED, FINISHED}

  struct Proposal {

    uint8 stage;

    uint8 proposalType;

    string ipfsDetails;

  }

  function proposeParamVote(
    uint8 _type,
    string ipfsDetails
  ) external;

  function proposeNewFormula(
    string formulaOnIpfs
  ) external;

  function cancelProposal(
    uint256 nonce;
  ) external;

  function vote(
    uint256 nonce
  ) external;

}
