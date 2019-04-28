const VotingCredit = artifacts.require('VotingCredit');

var increaseTime = require('./helpers/increaseTime')

contract('VotingCredit', function (accounts) {

  const proposalDuration = 60 * 60 * 24 * 60; //60 days

  var voting;

  beforeEach('Setting up', async () => {

    voting = await VotingCredit.new(proposalDuration, {from: accounts[0]});

  })

  it("should successfuly propose a param vote", async () => {

    await voting.proposeParamVote(
      0,
      "Bank Spam",
      0,
      -40,
      "some_ipfs_details",
      {from: accounts[1]}
    );

    var proposalStage = await voting.getProposalStage(0);
    var proposalType = await voting.getProposalType(0);
    var proposalParamName = await voting.getProposalParamName(0);
    var proposalLevel = await voting.getProposalParamLevel(0);
    var proposalPoints = await voting.getProposalParamPoints(0);
    var proposalIPFS = await voting.getProposalIPFSDetails(0);
    var proposalCreator = await voting.getProposalCreator(0);
    var proposalResult = await voting.getProposalResult(0);

    assert(proposalStage.toString() == "0", "The stage is not zero")
    assert(proposalType.toString() == "0", "The type is not zero")
    assert(proposalParamName.toString() == "Bank Spam", "The param name is not Bank Spam")
    assert(proposalLevel.toString() == "0", "The level is not zero")
    assert(proposalPoints.toString() == "-40", "The points are not -40")
    assert(proposalIPFS.toString() == "some_ipfs_details", "The IPFS link is not some_ipfs_details")
    assert(proposalCreator.toString() == accounts[1].toString(), "The creator is not accounts[1]")
    assert(proposalResult.toString() == "false", "The result is not false")

  })

  it("should successfuly propose a new formula", async () => {



  })

  it("should successfuly cancel a proposal", async () => {



  })

  it("should successfuly vote on a proposal", async () => {



  })

  it("should successfuly count the votes and register the result", async () => {



  })

})
