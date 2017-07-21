pragma solidity ^0.4.13;

// TODO: make that upgradeable

import "./StakeToken.sol";
import "zeppelin/contracts/ownership/Ownable.sol";
import "zeppelin/contracts/ReentrancyGuard.sol";

contract BasicDBVN is Ownable, ReentrancyGuard {
  uint public minimumQuorum;
  uint public debatingPeriod;

  Proposal[] public proposals;
  uint public numberOfProposals;

  // The ERC20 token is used as shares
  StakeToken public sharesToken;

  event ProposalAdded(uint proposalID, bytes32 transactionBytecode, string description);
  event ProposalTallied(uint proposalID, uint result, uint quorum, bool active);

  event Voted(uint proposalID, uint voteID, bool inSupport, address voter);

  event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes);

  event Deposit(address sender, uint value);

  struct Proposal {
    address submitter;

    address recipient;
    uint amount;

    uint votingDeadline;

    bool executed;
    bool executionSuccess; // Used to log if we succeed executing the proposal
    bool proposalPassed;

    bytes32 proposalHash;

    uint numberOfVotes;
    Vote[] votes;
    mapping (address => bool) voted;
  }

  struct Vote {
    bool inSupport;
    address voter;
  }

  modifier onlyShareholders {
    require(sharesToken.balanceOf(msg.sender) != 0);
    _;
  }

  function BasicDBVN(uint minimumSharesToPassAVote, uint minutesForDebate, uint initialShares) {
    // We deploy STK
    sharesToken = new StakeToken();
    sharesToken.mint(msg.sender, initialShares);

    changeVotingRules(minimumSharesToPassAVote, minutesForDebate);
  }

  function changeVotingRules(uint minimumSharesToPassAVote, uint minutesForDebate) onlyOwner {
    require(minimumSharesToPassAVote > 0);

    minimumQuorum = minimumSharesToPassAVote;
    debatingPeriod = minutesForDebate * 1 minutes;

    ChangeOfRules(minimumSharesToPassAVote, minutesForDebate);
  }

  function newProposal(address beneficiary, uint etherAmount, string JobDescription, bytes32 transactionBytecode) onlyShareholders returns (uint proposalID) {
    proposalID = proposals.length++;

    Proposal p = proposals[proposalID];
    p.submitter = msg.sender;
    p.recipient = beneficiary;
    p.amount = etherAmount;
    p.proposalHash = sha3(beneficiary, etherAmount, transactionBytecode);
    p.votingDeadline = now + debatingPeriod;

    numberOfProposals += 1;

    ProposalAdded(proposalID, transactionBytecode, JobDescription);
  }

  function checkProposalCode(uint proposalNumber, bytes32 transactionBytecode) constant returns (bool hashIsValid) {
    Proposal p = proposals[proposalNumber];
    hashIsValid = p.proposalHash == sha3(p.recipient, p.amount, transactionBytecode);
  }

  function vote(uint proposalNumber, bool inFavorOfProposal) onlyShareholders returns (uint voteID) {
    Proposal p = proposals[proposalNumber];

    require(!p.executed);
    require(!p.voted[msg.sender]);

    voteID = p.votes.length++;
    p.votes[voteID] = Vote({inSupport: inFavorOfProposal, voter: msg.sender});
    p.voted[msg.sender] = true;
    p.numberOfVotes += 1;

    Voted(proposalNumber, voteID, inFavorOfProposal, msg.sender);
  }

  function executeProposal(uint proposalNumber, bytes32 transactionBytecode) nonReentrant {
    // First, check a few things
    require(checkProposalCode(proposalNumber, transactionBytecode));

    Proposal p = proposals[proposalNumber];

    require(p.votingDeadline > now);
    require(!p.executed);

    // Time to tally the votes
    uint quorum = 0;
    uint yea = 0;
    uint nay = 0;

    for (uint i = 0; i <  p.votes.length; ++i) {
      Vote memory v = p.votes[i];
      uint voteWeight = sharesToken.balanceOf(v.voter);
      quorum += voteWeight;
      if (v.inSupport) {
        yea += voteWeight;
      } else {
        nay += voteWeight;
      }
    }

    // Execute result

    // Not enough voters
    assert(quorum >= minimumQuorum);

    p.executed = true;

    if (yea > nay ) {
      // Approved
      p.proposalPassed = true;
      if (p.recipient.call.value(p.amount * 1 ether)(transactionBytecode)) {
        p.executionSuccess = true;
      }
    }

    // Fire Events
    ProposalTallied(proposalNumber, yea - nay, quorum, p.proposalPassed);
  }

  function () payable {
    require(msg.value > 0);
    // Log the fact someone deposited ETH, so you can buy him a beer, or something else
    Deposit(msg.sender, msg.value);
  }
}
